require 'test/unit'
require 'FileUtils'
require_relative '../ocr_pso'
require_relative '../csv_image_factory'
require_relative '../non_det_ocr_pso'
require_relative '../non_det_automata'


class AlienElementsTest < Test::Unit::TestCase

  def test_ocr_with_alien_elements
    #init the pso object
    learning_set_filepath = 'learning_images.csv'
    test_set_filepath = 'test_images.csv'
    symbols_list = Automata.generate_symbols_list(4)
    states_count = 10

    #############################################################
    ######## generate the learning set ##########################
    # parameters
    no_of_classes = 10
    no_of_characteristics = 5
    no_of_objects = 20

    learn_set_sigma = 0.2
    test_set_sigma = 0.2

    # init image classes
    CsvImageFactory.instance.generate_image_templates(no_of_classes, no_of_characteristics)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, learn_set_sigma, learning_set_filepath, no_of_objects)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, test_set_sigma, test_set_filepath, no_of_objects)
    ################################################################
    #################################################################

    pso = OCR_PSO.new(symbols_list, states_count,learning_set_filepath)

    #################################################################
    ######## problem configuration ##################################
    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0, states_count-1] }
    images_count = pso.images_count
    puts "we have #{no_of_classes} different symbols"

    # algorithm configuration
    vel_space = Array.new(problem_size) { |i| [-3, 3] }
    max_gens = 1000
    pop_size = 15
    max_vel = 3.0
    c1, c2 = 1.0, 1.0
    #####################################################################
    #####################################################################

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    rounded_best_vector = best[:position].map{|val| val.round }
    puts "done! Solution: f=#{best[:cost]}"
    puts 'Transition matrix:'

    # test the test set
    a = Automata.new(symbols_list, states_count)
    a.set_transition_matrices_from_vector(best[:position])

    a.print_transition_matrix
    test_set = OCR_PSO.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(test_set_filepath), symbols_list)

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

  def test_ocr_with_alien_images_recognition
    #init the pso object
    learning_set_filepath = 'learning_images.csv'
    test_set_filepath = 'test_images.csv'
    symbols_list = Automata.generate_symbols_list(4)
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
    CsvImageFactory.instance.generate_images_csv(no_of_objects, learn_set_sigma, learning_set_filepath, no_of_objects)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, test_set_sigma, test_set_filepath, no_of_objects)
    ################################################################
    #################################################################
    states_count += 1
    rejecting_states = [states_count -1]

    pso = OCR_PSO.new(symbols_list, states_count,learning_set_filepath, rejecting_states)

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
    max_vel = 3.0
    c1, c2 = 1.5, 1.0
    #####################################################################
    #####################################################################

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    rounded_best_vector = best[:position].map{|val| val.round }
    puts "done! Solution: f=#{best[:cost]}"
    puts 'Transition matrix:'

    # test the test set
    a = Automata.new(symbols_list, states_count, nil, rejecting_states)
    a.set_transition_matrices_from_vector(best[:position])

    a.print_transition_matrix
    test_set = OCR_PSO.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(test_set_filepath), symbols_list)

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

  def test_non_deterministic_ocr
    #init the pso object
    learning_set_filepath = 'learning_images.csv'
    test_set_filepath = 'test_images.csv'
    symbols_list = Automata.generate_symbols_list(4)
    states_count = 10

    #############################################################
    ######## generate the learning set ##########################
    # parameters
    no_of_classes = 10
    no_of_characteristics = 5
    no_of_objects = 20

    learn_set_sigma = 0.1
    test_set_sigma = 0.1

    non_det_val = 3

    # init image classes
    CsvImageFactory.instance.generate_image_templates(no_of_classes, no_of_characteristics)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, learn_set_sigma, learning_set_filepath)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, test_set_sigma, test_set_filepath)
    ################################################################
    #################################################################
    rejecting_states = []
    states_count += rejecting_states.count

    pso = NON_DET_OCR_PSO.new(symbols_list, states_count,learning_set_filepath, non_det_val, rejecting_states)

    #################################################################
    ######## problem configuration ##################################
    problem_size = states_count * states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0.0, 1.0] }
    images_count = pso.images_count
    puts "we have #{no_of_classes} different symbols"

    # algorithm configuration
    max_vel = 0.1
    vel_space = Array.new(problem_size) { |i| [-max_vel, max_vel] }
    max_gens = 1000
    pop_size = 5
    c1, c2 = 2.0, 1.0
    #####################################################################
    #####################################################################

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    rounded_best_vector = best[:position].map{|val| val.round }
    puts "done! Solution: f=#{best[:cost]}"
    puts 'Transition matrix:'

    # test the test set
    a = NdAutomata.new(symbols_list, states_count, nil, non_det_val, rejecting_states)
    a.set_transition_matrices_from_vector(best[:position])

    a.print_transition_matrix
    test_set = OCR_PSO.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(test_set_filepath), symbols_list)

    puts
    puts 'Testing generated automata on test set...'
    errors_count = 0
    test_set.each do |image|
      end_states = a.compute_word(image.word)
      errors_count += 1 if not end_states[image.image_class] == 1
    end
    puts "Errors count #{errors_count}"
    puts "#{(100.0 - errors_count*100.0/images_count)}% of test images computed correctly!"
    assert_in_delta(0, errors_count, images_count/2)
  end

  def test_non_det_with_alien_images_recognition
    #init the pso object
    learning_set_filepath = 'learning_images.csv'
    test_set_filepath = 'test_images.csv'
    symbols_list = Automata.generate_symbols_list(4)
    states_count = 10

    #############################################################
    ######## generate the learning set ##########################
    # parameters
    no_of_classes = 10
    no_of_characteristics = 5
    no_of_objects = 20

    learn_set_sigma = 0.1
    test_set_sigma = 0.15

    non_det_val = 2

    # init image classes
    CsvImageFactory.instance.generate_image_templates(no_of_classes, no_of_characteristics)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, learn_set_sigma, learning_set_filepath, no_of_objects)
    CsvImageFactory.instance.generate_images_csv(no_of_objects, test_set_sigma, test_set_filepath, no_of_objects)
    ################################################################
    #################################################################
    rejecting_states = [states_count]
    states_count += rejecting_states.count

    pso = NON_DET_OCR_PSO.new(symbols_list, states_count,learning_set_filepath, non_det_val, rejecting_states)

    #################################################################
    ######## problem configuration ##################################
    problem_size = states_count * states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0.0, 1.0] }
    images_count = pso.images_count
    puts "we have #{no_of_classes} different symbols"

    # algorithm configuration
    max_vel = 0.1
    vel_space = Array.new(problem_size) { |i| [-max_vel, max_vel] }
    max_gens = 300
    pop_size = 5
    c1, c2 = 1.5, 1.0
    #####################################################################
    #####################################################################

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    rounded_best_vector = best[:position].map{|val| val.round }
    puts "done! Solution: f=#{best[:cost]}"
    puts 'Transition matrix:'

    # test the test set
    a = NdAutomata.new(symbols_list, states_count, nil, non_det_val, rejecting_states)
    a.set_transition_matrices_from_vector(best[:position])

    a.print_transition_matrix
    test_set = OCR_PSO.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(test_set_filepath), symbols_list)

    puts
    puts 'Testing generated automata on test set...'
    errors_count = 0
    alien_images_recognized = 0
    test_set.each do |image|
      end_states = a.compute_word(image.word)
      if image.image_class == -1
        errors_count += 1 if not a.is_in_rejecting_state?
        alien_images_recognized += 1 if a.is_in_rejecting_state?
      else if not end_states[image.image_class] == 1
             errors_count += 1
           end
      end
    end
    puts "aliens found: #{alien_images_recognized}"
    puts "Errors count #{errors_count}"
    puts "#{(100.0 - errors_count*100.0/images_count)}% of test images computed correctly!"
    assert_in_delta(0, errors_count, images_count/2)
  end

end