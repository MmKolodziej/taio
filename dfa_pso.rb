require_relative "pso.rb"
require_relative "automata.rb"

class DFA_PSO < PSO

  # Init in initializer.
  CORRECT_WORDS   = ['0', '1000', '101111', '1', '1010111001', '1010101010101', '111']
  INCORRECT_WORDS = ['00', '01', '0101110', '01010101010', '000100010', '0000101010000101']

  def initialize(symbols_list, states_count, accepting_states)
    self.accepting_states = accepting_states
    self.dfa = Automata.new(symbols_list, states_count, nil)
  end

  def objective_function(vector)

    errors_count = 0
    @dfa.set_transition_matrix_from_vector(vector)
    self.errors_count = 0

    dfa.set_transition_matrix_from_vector(vector) #TODO: implement this in automata class

    CORRECT_WORDS.each do |word|
      increment_errors_count unless accepting_states.include?(dfa.compute_word(word))
    end

    INCORRECT_WORDS.each do |word|
      increment_errors_count if accepting_states.include?(dfa.compute_word(word))
    end

    self.errors_count
  end

  attr_accessor :errors_count, :accepting_states, :dfa, :correct_words, :incorrect_words

  def increment_errors_count
    self.errors_count += 1
  end
end
