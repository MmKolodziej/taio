require_relative'dfa_pso.rb'
require_relative'image_sample.rb'

class OCR_PSO < PSO
  def initialize(symbols_list, states_count, images_filepath, verbose = true)
    self.verbose = verbose

    self.dfa = Automata.new(symbols_list, states_count, nil)

    self.states_count = states_count
    self.symbols_list = symbols_list

    #init images from filepath
    self.sample_images = OCR_PSO.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(images_filepath),symbols_list)
  end

  attr_accessor :symbols_list, :states_count, :dfa, :sample_images, :verbose

  def self.create_words_from_image_vectors(images, symbols_list)
    range_size = 1.to_f/symbols_list.size

    images.each do |image|
      word = []
      image.get_characteristics.each do |coeficient|
        symbol_index = (coeficient / range_size).to_i - 1
        word << symbols_list[symbol_index]
      end
      image.set_word(word)
    end
  end

  def objective_function(vector)
    #let the dfa compute each of the images, and assign (dfa's end state) them to a class.
    #returns the number of images assigned to wrong class

    rounded_vector = vector.map { |val| val.to_i }
    dfa.set_transition_matrix_from_vector(rounded_vector)
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




