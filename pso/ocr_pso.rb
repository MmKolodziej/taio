require_relative '../automata/deterministic_automata'
require_relative 'pso.rb'
require_relative '../image_sample'

class OCR_PSO < PSO
  def initialize(symbols_list, states_count, images_filepath, rejecting_states = [], verbose = true)
    self.verbose = verbose

    self.dfa = DeterministicAutomata.new(symbols_list, states_count, nil, rejecting_states)

    self.states_count = states_count
    self.symbols_list = symbols_list

    #init images from filepath
    self.sample_images = OCR_PSO.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(images_filepath),symbols_list)
  end

  attr_accessor :symbols_list, :states_count, :dfa, :sample_images, :verbose

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

    dfa.set_transition_matrices_from_vector(vector)
    errors_count = 0

    sample_images.each do |image|
      end_state = dfa.compute_word(image.word)
      if end_state != image.image_class
        errors_count += 1
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




