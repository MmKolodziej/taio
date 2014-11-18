require_relative 'base_automata'

class NonDeterministicAutomata < BaseAutomata
  # each row in a transistion matrix can contain more than one '1'
  #symbols_list: list of symbols that the automata can process (eg.: '0,1' , 'a,b,c' etc)
  def initialize(symbols_list, states_count, transition_matrices=nil, no_of_possible_states = 3, rejecting_states = [])
    super(symbols_list, states_count, transition_matrices, rejecting_states)

    self.possible_states_count = no_of_possible_states
    self.current_states = reset_current_states
  end

  # word: a list of symbols for the automata to compute (eg.: 'aabccaaa')
  # returns: End state if computations successfull, False if word does not belong to automata alphabet
  def compute_word(word)
    return unless word_is_from_alphabet?(word)

    word.each do |symbol|
      self.current_states = compute_symbol(symbol)
    end

    end_states = current_states

    # reset the current_state for future computations
    self.current_states = reset_current_states

    end_states
  end

  def set_transition_matrices_from_vector(vector)
    rounded_vector = vector.map {|v| v.round}
    matrix_index, row_index = 0, 0

    while matrix_index < symbols_list.count
      while row_index < states_count
        vector_index = matrix_index * states_count * states_count + row_index * states_count
        transition_matrices[matrix_index][row_index] = rounded_vector[vector_index..(vector_index + states_count - 1)]
        row_index += 1
      end

      matrix_index += 1
      row_index = 0
    end
  end

  private

  attr_accessor :current_states, :possible_states_count

  def reset_current_states
    states = Array.new(states_count){0}
    states[0] = 1
    states
  end

  def multiply_matrix_by_vector(matrix, vector)
    # the idea is, if we can go to state x from 3 different states
    # (assuming these are our current states),
    # then result[x] = 3
    result = []

    matrix.each do |row|
      val = 0
      row.each_with_index { |cell,index | val += cell * vector[index] }
      result << val
    end
    result
  end

  def limit_states(states_vector)
    #sorted_indexes contains indexes of sorted elements of the states_vector
    sorted_indexes = states_vector.each_with_index.sort.map(&:last)

    limited_states_vector = Array.new(states_count){0}
    # we take only the top 'possible_states_count' states
    sorted_indexes.last(possible_states_count).each do |index|
      limited_states_vector[index] = 1
    end
    limited_states_vector
  end

  # Computes a single symbol -> changes the automata's current state to the appropriate one.
  # symbol: the symbol to be computed (eg.: '0', 'a', 'X')
  def compute_symbol(symbol)
    matrix = transition_matrices[symbols_list.index(symbol)]
    states = multiply_matrix_by_vector(matrix, current_states)
    limit_states(states)
  end
end
