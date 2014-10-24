require_relative'dfa_pso.rb'
require_relative'sample_image.rb'

class OCR_PSO < Rounded_PSO
  def initialize(symbols_list, states_count, images_filepath, verbose = true)
    self.verbose = verbose

    self.dfa = Automata.new(symbols_list, states_count, nil)

    self.states_count = states_count
    self.symbols_list = symbols_list

    #init images from filepath
    self.sample_images = adjust_images(ImageSample.create_multiple_from_csv(images_filepath),symbols_list)
  end

  attr_accessor :symbols_list, :states_count, :dfa, :sample_images, :verbose

  def adjust_images(images,symbols)
    adjusted = []
    intervals = symbols.count

    images.each do |image|
      word = []
      image.get_characteristics.each do |val|
        symbols_index = ((val * intervals).to_i) + 1
        symbol = symbols_list[symbols_index]
        word << symbol
      end
      image.set_word(word)
    end
  end

  def objective_function(vector)
    #let the dfa compute each of the images, and assign (dfa's end state) them to a class.
    #returns the number of images assigned to wrong class

    dfa.set_transition_matrix_from_vector(vector)
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




