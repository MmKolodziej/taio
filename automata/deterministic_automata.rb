require_relative 'base_automata'

class DeterministicAutomata < BaseAutomata
  def initialize(symbols_list, states_count, transition_matrices=nil, rejecting_states = [])
    super

    self.current_state = 0
  end

  # word: a list of symbols for the automata to compute (eg.: 'aabccaaa')
  # returns: End state if computations successfull, False if word does not belong to automata alphabet
  def compute_word(word)
    return unless word_is_from_alphabet?(word)

    word.each do |symbol|
      self.current_state = compute_symbol(symbol)
    end

    end_state = current_state
    # end_state = -1 if rejecting_states && rejecting_states.include?(end_state)

    # reset the current_state for future computations
    self.current_state = 0

    end_state
  end

  def set_transition_matrices_from_vector(vector)
    matrix_index, row_index = 0, 0

    while matrix_index < symbols_list.count
      while row_index < states_count
        vector_index = matrix_index * states_count + row_index
        transition_matrices[matrix_index][row_index] = Array.new(states_count){0}
        transition_matrices[matrix_index][row_index][vector[vector_index].round] = 1
        row_index += 1
      end

      matrix_index += 1
      row_index = 0
    end
  end

  private

  attr_accessor :current_state

  # Computes a single symbol -> changes the automata's current state to the appropriate one.
  # symbol: the symbol to be computed (eg.: '0', 'a', 'X')
  def compute_symbol(symbol)
    transition_matrices[symbols_list.index(symbol)][current_state].index {|val| val == 1}
  end
end
