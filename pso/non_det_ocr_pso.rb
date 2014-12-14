require_relative '../automata/non_deterministic_automata'
require_relative 'pso.rb'
require_relative '../image_generation/image_sample'
require_relative 'ocr_pso'

class NonDetOcrPso < OcrPso
  def initialize(symbols_list, states_count, images_filepath, has_rejecting_states, no_of_possible_states = 3, verbose = true)
    super(symbols_list, states_count, images_filepath,has_rejecting_states, verbose)

    no_of_possible_states = 3 if no_of_possible_states == nil

    self.automata = NonDeterministicAutomata.new(symbols_list, self.states_count, nil, no_of_possible_states, self.rejecting_states)
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




