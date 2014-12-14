require_relative '../automata/deterministic_automata'
require_relative 'pso.rb'
require_relative '../image_generation/image_sample'

class OcrPso < PSO
  def initialize(symbols_list, states_count, images_filepath, has_rejecting_states, verbose = true, skip_duplicates = false)
    self.verbose = verbose
    self.symbols_list = symbols_list
    self.has_rejecting_states = has_rejecting_states
    #init images from filepath
    self.sample_images = OcrPso.create_words_from_image_vectors(ImageFactory.instance.load_sample_images_from_csv(images_filepath),symbols_list, skip_duplicates)

    # if states_count not passed explicitly, it is equal to the number of different image classes
    self.states_count = self.classes_count if states_count == 0 || states_count == nil
    self.rejecting_states = has_rejecting_states ? [self.states_count - 1] : []

    self.automata = DeterministicAutomata.new(symbols_list, self.states_count, nil, self.rejecting_states)
  end

  attr_accessor :symbols_list, :states_count, :automata, :sample_images, :verbose, :has_rejecting_states, :rejecting_states

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
    count = sample_images.uniq { |img| img.image_class}.size
    count += -1 if not self.has_rejecting_states
    count
  end

  def images_count
    sample_images.count
  end

  def print_progress(gen, fitness, iterations_wo_change)
    puts "> gen #{gen+1}, errors count: #{fitness} (#{((fitness.to_f/sample_images.count)*100.0).round}%), iterations without change: #{iterations_wo_change}"
  end

end

