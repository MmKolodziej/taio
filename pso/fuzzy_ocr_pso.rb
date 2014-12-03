require_relative '../automata/fuzzy_automata'
require_relative 'pso.rb'
require_relative '../image_generation/image_sample'
require_relative 'ocr_pso'

class FuzzyOcrPso < OcrPso
  def initialize(symbols_list, states_count, images_filepath, rejecting_states = [], verbose = true)
    super(symbols_list, states_count, images_filepath, rejecting_states, verbose)
    self.automata = FuzzyAutomata.new(symbols_list, states_count, nil, rejecting_states)
  end

  def cost_function(states, image)
    FuzzyOcrPso.weighted_percentage_cost(states, image.image_class)
  end

  # COST FUNCTIONS
  def self.raw_cost(end_states, image_class)
    error = 0
    end_states.each_with_index do |weight_of_class, index_of_class|
      error += 1 if (index_of_class == image_class && weight_of_class < 1) || weight_of_class >= 1
      end
    error
  end

  def self.weighted_percentage_cost(end_states, image_class)
    # returns correct_state_weight to sum_of_all_weights ratio
    # say, for [0.2,0.3,0.95]: 0.95/(0.95+0.3+0.2)
    error_percentage = end_states[image_class] / (end_states.inject(:+))
    1 - error_percentage
  end

  def self.weighted_max_cost(end_states, image_class)
    # if the maximum state is the correct one, then returns 1 - weight of the state
    # else, returns 1
    max_state = end_states.max
    return end_states.index(max_state) == image_class ? 1 - max_state : 1
  end

  def self.weighted_cost(end_states, image_class)
    error = 0
    end_states.each_with_index do |weight, index_of_class|
      class_error = index_of_class == image_class ? 1 : 0
      error += (class_error - weight).abs
    end
    error
  end

end




