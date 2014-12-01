require_relative '../automata/fuzzy_automata'
require_relative 'pso.rb'
require_relative '../image_generation/image_sample'
require_relative 'ocr_pso'

class FuzzyOcrPso < OcrPso
  def initialize(symbols_list, states_count, images_filepath, rejecting_states = [], verbose = true)
    self.verbose = verbose

    self.f_automata = FuzzyAutomata.new(symbols_list, states_count, nil, rejecting_states)

    self.states_count = states_count
    self.symbols_list = symbols_list

    #init images from filepath
    self.sample_images = FuzzyOcrPso.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(images_filepath),symbols_list)
  end

  attr_accessor :symbols_list, :states_count, :f_automata, :sample_images, :verbose

  def self.create_words_from_image_vectors(images, symbols_list)

    images.each do |image|
      word = []
      image.get_characteristics.each do |coeficient|
        symbol_index = coeficient == 1.0 ? symbols_list.size-1 : (coeficient * symbols_list.size).to_i
        word << symbols_list[symbol_index]
      end
      image.set_word(word)
    end
  end

  def objective_function(vector)
    #let the dfa compute each of the images, and assign (dfa's end state) them to a class.
    #returns the number of images assigned to wrong class

    f_automata.set_transition_matrices_from_vector(vector)
    errors_count = 0

    sample_images.each do |image|
      end_states = f_automata.compute_word(image.word)
      errors_count += FuzzyOcrPso.weighted_percentage_cost(end_states, image)
    end

    errors_count
  end


  # COST FUNCTIONS
  def self.raw_cost(end_states, image)
    error = 0
    end_states.each_with_index do |weight, images_class|
      if images_class == image.image_class
        error += 1 if weight < 1
      else
        error += 1 if weight >= 1
      end
    end
    error
  end

  def self.weighted_percentage_cost(end_states, image)
    # returns correct_state_weight to sum_of_all_weights ratio
    # say, for [0.2,0.3,0.95]: 0.95/(0.95+0.3+0.2)
    error_percentage = end_states[image.image_class] / (end_states.inject(:+))
    1 - error_percentage
  end

  def self.weighted_max_cost(end_states, image)
    # if the maximum state is the correct one, then returns 1 - weight of the state
    # else, returns 1
    error = 0
    max_state = end_states.max
    if end_states.index(max_state) == image.image_class
      error += 1 - max_state
    else
     error = 1
    end

    error
  end

  def self.weighted_cost(end_states, image)
    error = 0
    end_states.each_with_index do |weight, images_class|
      class_error = images_class == image.image_class ? 1 : 0
      error += (class_error - weight).abs
    end
    error
  end

end




