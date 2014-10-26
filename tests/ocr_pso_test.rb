require 'test/unit'
require_relative '../ocr_pso'
require_relative '../csv_image_factory'

class MyTest < Test::Unit::TestCase

  def test_ocr_pso
    #init the pso object
    images_filepath = 'images_1.csv'
    symbols_list = Automata.generate_symbols_list(4)
    states_count = 7

    pso =  OCR_PSO.new(symbols_list, states_count,images_filepath, false)

    # problem configuration
    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0, states_count-1] } #TODO: check if this are inclusive or exclusive boundaries
    image_classess = pso.classes_count
    images_count = pso.images_count
    puts "we have #{image_classess} different symbols"

    # algorithm configuration
    vel_space = Array.new(problem_size) { |i| [-1, 1] }
    max_gens = 100
    pop_size = 800
    max_vel = 100.0
    c1, c2 = 3.0, 1.0

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    puts "done! Solution: f=#{best[:cost]}, s=#{best[:position].inspect}"

    #we can compute at most half of the words incorrectly
    assert_in_delta(0,best[:cost],images_count/2)
  end

  def test_ocr_from_csv
    #init the pso object
    learning_set_filepath = 'learning_images.csv'
    test_set_filepath = 'test_images.csv'
    symbols_list = Automata.generate_symbols_list(4)
    states_count = 5

    #############################################################
    ######## generate the learning set ##########################
    # parameters
    no_of_classes = 10
    no_of_characteristics = 5
    no_of_objects = 20

    sigma = 0.4

    # init image classes
    CsvImageFactory.instance.generate_image_templates(no_of_classes, no_of_characteristics)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, sigma, learning_set_filepath)
    ################################################################
    #################################################################

    pso =  OCR_PSO.new(symbols_list, states_count,learning_set_filepath)

    #################################################################
    ######## problem configuration ##################################
    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0, states_count-1] }
    images_count = pso.images_count
    puts "we have #{no_of_classes} different symbols"

    # algorithm configuration
    vel_space = Array.new(problem_size) { |i| [-3, 3] }
    max_gens = 100
    pop_size = 50
    max_vel = 2.5
    c1, c2 = 1.5, 1.0
    #####################################################################
    #####################################################################

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)

    puts "done! Solution: f=#{best[:cost]}, s=#{best[:position].map{|val| val.round }.inspect}"
    #we can compute at most half of the words incorrectly
    assert_in_delta(0,best[:cost],images_count/2)
  end
end