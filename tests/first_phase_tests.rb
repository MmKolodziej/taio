require 'test/unit'
require_relative '../pso/ocr_pso'
require_relative '../image_generation/csv_image_factory'

class FirstPhaseTests < Test::Unit::TestCase

  LEARNING_SET_FILEPATH = 'test_data/learning_images.csv'
  TEST_SET_FILEPATH = 'test_data/test_images.csv'

  def test_ocr_pso
    #init the pso object
    images_filepath = 'test_data/images_1.csv'
    symbols_list = DeterministicAutomata.generate_symbols_list(4)
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
    max_gens = 1000
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

    symbols_list = DeterministicAutomata.generate_symbols_list(4)
    states_count = 10

    #############################################################
    ######## generate the learning set ##########################
    # parameters
    no_of_classes = 10
    no_of_characteristics = 5
    no_of_objects = 20

    learn_set_sigma = 0.1
    test_set_sigma = 0.1

    # init image classes
    CsvImageFactory.instance.generate_image_templates(no_of_classes, no_of_characteristics)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, learn_set_sigma, LEARNING_SET_FILEPATH)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, test_set_sigma, TEST_SET_FILEPATH)
    ################################################################
    #################################################################

    pso = OCR_PSO.new(symbols_list, states_count, LEARNING_SET_FILEPATH)

    #################################################################
    ######## problem configuration ##################################
    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0, states_count-1] }
    images_count = pso.images_count
    puts "we have #{no_of_classes} different symbols"

    # algorithm configuration
    vel_space = Array.new(problem_size) { |i| [-3, 3] }
    max_gens = 1000
    pop_size = 5
    max_vel = 2.5
    c1, c2 = 1.0, 1.0
    #####################################################################
    #####################################################################

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    rounded_best_vector = best[:position].map{|val| val.round }
    puts "done! Solution: f=#{best[:cost]}"
    puts 'Transition matrix:'

    # test the test set
    a = DeterministicAutomata.new(symbols_list, states_count)
    a.set_transition_matrices_from_vector(best[:position])

    a.print_transition_matrix
    test_set = OCR_PSO.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(TEST_SET_FILEPATH), symbols_list)

    puts
    puts 'Testing generated automata on test set...'
    errors_count = 0
    test_set.each do |image|
      end_state = a.compute_word(image.word)
      errors_count += 1 if end_state != image.image_class
    end
    puts "Errors count #{errors_count}"
    puts "#{(100.0 - errors_count*100.0/images_count)}% of test images computed correctly!"
    assert_in_delta(0, errors_count, images_count/2)
  end
end