require_relative 'non_deterministic_automata'

class FuzzyAutomata < NonDeterministicAutomata
  # each row in a transistion matrix can contain more than one '1'
  #symbols_list: list of symbols that the automata can process (eg.: '0,1' , 'a,b,c' etc)
  def initialize(symbols_list, states_count, transition_matrices=nil, rejecting_states = [])
    super(symbols_list, states_count, transition_matrices, 3, rejecting_states)

    self.current_states = reset_current_states
  end

  def set_transition_matrices_from_vector(vector)
    matrix_index, row_index = 0, 0

    while matrix_index < symbols_list.count
      while row_index < states_count
        vector_index = matrix_index * states_count * states_count + row_index * states_count
        transition_matrices[matrix_index][row_index] = vector[vector_index..(vector_index + states_count - 1)]
        row_index += 1
      end

      matrix_index += 1
      row_index = 0
    end
  end

  private

  attr_accessor :current_states

  def limit_states(states_vector)
    #sorted_indexes contains indexes of sorted elements of the states_vector
    sorted_indexes = states_vector.each_with_index.sort.map(&:last)
    limited_states_vector = Array.new(states_count){0}
    # we take only the top 'possible_states_count' states
    sorted_indexes.last(possible_states_count).each do |index|
      limited_states_vector[index] = states_vector[index]
    end
    limited_states_vector
  end

  def multiply_matrix_by_vector(matrix, vector)
    # the idea is, if we can go to state x from 3 different states
    # (assuming these are our current states),
    # then result[x] = 3
    result = []
    matrix.each do |row|
      val = 0
      row.each_with_index { |cell,index | val = max_function(min_function(cell, vector[index]), val) }
      result << val
    end
    result
  end

  # MAX and MIN functions

  def max_function(a, b)
    simple_max(a, b)
  end

  def min_function(a, b)
    simple_min(a,b)
  end

  def atanh_max(a, b)
    Math.tanh(Math.atanh(a) + Math.atanh(b))
  end

  def atanh_min(a, b)
    1 - Math.tanh(Math.atanh(1 - a) + Math.atanh(1 - b))
  end

  def simple_max(a,b)
    a > b ? a : b
  end

  def simple_min(a,b)
    a < b ? a : b
  end

end
