require_relative '../automata/non_deterministic_automata'
require_relative 'pso.rb'
require_relative '../image_generation/image_sample'
require_relative 'ocr_pso'

class NonDetOcrPso < OcrPso
  def initialize(symbols_list, states_count, images_filepath, no_of_possible_states = 3, rejecting_states = [], verbose = true)
    self.verbose = verbose

    self.automata = NonDeterministicAutomata.new(symbols_list, states_count, nil, no_of_possible_states, rejecting_states)

    self.states_count = states_count
    self.symbols_list = symbols_list

    #init images from filepath
    self.sample_images = NonDetOcrPso.create_words_from_image_vectors(CsvImageFactory.instance.load_sample_images_from_csv(images_filepath),symbols_list)
  end

  def cost_function(states, image)
    if image.image_class == -1
      return 1 if not automata.is_in_rejecting_state?
    else if not states[image.image_class] == 1
           return 1
         end
    end
    0
  end

end




