require_relative '../automata/deterministic_automata'
require_relative 'pso.rb'
require_relative '../image_generation/image_sample'

class OcrPso < PSO
  def initialize(symbols_list, states_count, images_filepath, rejecting_states = [], verbose = true, skip_duplicates = false)
    self.verbose = verbose
    self.symbols_list = symbols_list

    #init images from filepath
    self.sample_images = OcrPso.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(images_filepath),symbols_list, skip_duplicates)

    # if states_count not passed explicitly, it is equal to the number of different image classes
    states_count = classes_count if states_count == 0 || states_count == nil
    self.states_count = states_count

    self.automata = DeterministicAutomata.new(symbols_list, states_count, nil, rejecting_states)
  end

  attr_accessor :symbols_list, :states_count, :automata, :sample_images, :verbose

  def self.create_words_from_image_vectors(images, symbols_list, skip_duplicates = false)

    images.each do |image|
      word = []
      image.get_characteristics.each do |coeficient|
        symbol_index = coeficient == 1.0 ? symbols_list.size-1 : (coeficient * symbols_list.size).to_i
        word << symbols_list[symbol_index]
      end
      image.set_word(word)
    end

    if skip_duplicates
      puts "skipping duplicates"
      images.uniq! {|image| image.word }
    end

    images
  end

  def objective_function(vector)
    #let the dfa compute each of the images, and assign (dfa's end state) them to a class.
    #returns the number of images assigned to wrong class

    automata.set_transition_matrices_from_vector(vector)
    errors_count = 0

    sample_images.each do |image|
      end_states = automata.compute_word(image.word)
      errors_count += cost_function(end_states, image)
    end
    errors_count
  end

  def cost_function(state, image)
    return state != image.image_class ? 1 : 0
  end

  def classes_count
    # returns the number of unique image classses
    sample_images.uniq { |img| img.image_class}.size
  end

  def images_count
    sample_images.count
  end

  def print_progress(gen, fitness, iterations_wo_change)
    puts "> gen #{gen+1}, errors count: #{fitness} (#{((fitness.to_f/sample_images.count)*100.0).round}%), iterations without change: #{iterations_wo_change}"
  end

end

