require_relative '../automata/non_deterministic_automata'
require_relative 'pso.rb'
require_relative '../image_sample.rb'

class NON_DET_OCR_PSO < PSO
  def initialize(symbols_list, states_count, images_filepath, no_of_possible_states = 3, rejecting_states = [], verbose = true)
    self.verbose = verbose

    self.ndfa = NonDeterministicAutomata.new(symbols_list, states_count, nil, no_of_possible_states, rejecting_states)

    self.states_count = states_count
    self.symbols_list = symbols_list

    #init images from filepath
    self.sample_images = NON_DET_OCR_PSO.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(images_filepath),symbols_list)
  end

  attr_accessor :symbols_list, :states_count, :ndfa, :sample_images, :verbose

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

    ndfa.set_transition_matrices_from_vector(vector)
    errors_count = 0

    sample_images.each do |image|
      end_states = ndfa.compute_word(image.word)
      if image.image_class == -1
        alien_error = 1
        ndfa.rejecting_states.each {|state| alien_error = 0 if end_states[state] == 1}
        errors_count += alien_error
      else if not end_states[image.image_class] == 1
        errors_count += 1
           end
        end
    end

    errors_count
  end

  def classes_count
    # returns the number of unique image classses
    sample_images.uniq { |img| img.image_class}.size
  end

  def images_count
    sample_images.count
  end
end




