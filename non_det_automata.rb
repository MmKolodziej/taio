class NdAutomata
# deterministic automata
# each row in a transistion matrix can contain more than one '1'

#symbols_list: list of symbols that the automata can process (eg.: '0,1' , 'a,b,c' etc)
  def initialize(symbols_list, states_count, transition_matrices=nil, no_of_possible_states = 3, rejecting_states = [])
    if (symbols_list.uniq.count != symbols_list.count)
      puts "Symbols: #{symbols_list} are not unique!"
    end

    self.symbols_list = symbols_list
    self.states_count = states_count
    self.possible_states_count = no_of_possible_states
    self.current_states = reset_current_states
    self.rejecting_states = rejecting_states

    if transition_matrices
      self.transition_matrices = transition_matrices
    else
      init_transition_matrices
    end
  end

  # Computes a single symbol -> changes the automata's current state to the appropriate one.
  # symbol: the symbol to be computed (eg.: '0', 'a', 'X')
  def compute_symbol(symbol)
    matrix = transition_matrices[symbols_list.index(symbol)]
    states = multiply_matrix_by_vector(matrix, current_states)
    limit_states(states)
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

  def word_is_from_alphabet?(word)
    word.each do |symbol|
      return false unless symbols_list.include?(symbol)
    end

    true
  end

  def print_transition_matrix
    symbols_list.each do |symbol|
      puts "Transition matrix[#{symbol}] = "
      transition_matrices[symbols_list.index(symbol)].each { |row| puts row.inspect }
    end
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


  def is_in_rejecting_state?
    rejecting_states.each do |state|
      return true if current_states[state] == 1
    end
  end

  private

  attr_accessor :symbols_list, :states_count, :current_states, :transition_matrices, :rejecting_states, :possible_states_count


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

  # returns: Matrix n x m, where n = symbols count, m = states count, initialized with zeros.
  def init_transition_matrices
    self.transition_matrices = Array.new(symbols_list.count){Array.new(states_count){Array.new(states_count){0}}}
  end

  def self.generate_symbols_list(count)
    # generates a count - length array of symbols
    (0..count-1).map(&:to_s)
  end
end
