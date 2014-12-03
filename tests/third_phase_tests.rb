require 'test/unit'
require_relative '../pso/ocr_pso'
require_relative '../image_generation/csv_image_factory'
require_relative '../pso/fuzzy_ocr_pso'
require_relative '../automata/fuzzy_automata'

class ThirdPhaseTests < Test::Unit::TestCase

  LEARNING_SET_FILEPATH = 'test_data/learning_images.csv'
  TEST_SET_FILEPATH = 'test_data/test_images.csv'

  def test_fuzzy_ocr_pso
    #init the pso object
    symbols_list = FuzzyAutomata.generate_symbols_list(4)
    states_count = 10

    #############################################################
    ######## generate the learning set ##########################
    # parameters
    no_of_classes = 10
    no_of_characteristics = 5
    no_of_objects = 10

    learn_set_sigma = 0.2
    test_set_sigma = 0.2

    # init image classes
    CsvImageFactory.instance.generate_image_templates(no_of_classes, no_of_characteristics)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, learn_set_sigma, LEARNING_SET_FILEPATH)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, test_set_sigma, TEST_SET_FILEPATH)
    ################################################################
    #################################################################
    rejecting_states = []
    states_count += rejecting_states.count

    pso = FuzzyOcrPso.new(symbols_list, states_count, LEARNING_SET_FILEPATH, rejecting_states)

    #################################################################
    ######## problem configuration ##################################
    problem_size = states_count * states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0.0, 1.0] }
    images_count = pso.images_count
    puts "we have #{no_of_classes} different symbols"

    # algorithm configuration
    max_vel = 0.25
    vel_space = Array.new(problem_size) { |i| [-max_vel, max_vel] }
    max_gens = 10000
    pop_size = 5
    c1, c2 = 1.0, 1.0
    #####################################################################
    #####################################################################

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    puts "done! Solution: f=#{best[:cost]}"
    puts 'Transition matrix:'

    # test the test set
    a = FuzzyAutomata.new(symbols_list, states_count, nil, rejecting_states)
    a.set_transition_matrices_from_vector(best[:position])

    a.print_transition_matrix
    test_set = OcrPso.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(TEST_SET_FILEPATH), symbols_list)

    puts
    puts 'Testing generated automata on test set...'
    errors_count = 0
    test_set.each do |image|
      end_states = a.compute_word(image.word)
      errors_count += FuzzyOcrPso.weighted_percentage_cost(end_states, image)
    end
    puts "Errors count #{errors_count}"
    puts "#{(100.0 - errors_count*100.0/images_count)}% of test images computed correctly!"
    assert_in_delta(0, errors_count, images_count/2)
  end

end