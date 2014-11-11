class Automata
# deterministic automata

  #symbols_list: list of symbols that the automata can process (eg.: '0,1' , 'a,b,c' etc)
  def initialize(symbols_list, states_count, transition_matrices=nil)
    if (symbols_list.uniq.count != symbols_list.count)
      puts "Symbols: #{symbols_list} are not unique!"
    end

    self.symbols_list = symbols_list
    self.states_count = states_count
    self.current_state = 0

    if transition_matrices
      self.transition_matrices = transition_matrices
    else
      init_transition_matrices
    end
  end

  # Computes a single symbol -> changes the automata's current state to the appropriate one.
  # symbol: the symbol to be computed (eg.: '0', 'a', 'X')
  def compute_symbol(symbol)
    transition_matrices[symbols_list.index(symbol)][current_state].index {|val| val == 1}
  end

  # word: a list of symbols for the automata to compute (eg.: 'aabccaaa')
  # returns: End state if computations successfull, False if word does not belong to automata alphabet
  def compute_word(word)
    return unless word_is_from_alphabet?(word)

    word.each do |symbol|
      self.current_state = compute_symbol(symbol)
    end

    end_state = current_state

    # reset the current_state for future computations
    self.current_state = 0

    end_state
  end

  def word_is_from_alphabet?(word)
    word.each do |symbol|
      return false unless symbols_list.include?(symbol)
    end

    true
  end

  def print_transition_matrix
    symbols_list.each do |symbol|
      puts "Transition matrix[#{symbol}] = #{transition_matrices[symbols_list.index(symbol)]}"
    end
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

  attr_accessor :symbols_list, :states_count, :current_state, :transition_matrices

  # returns: Matrix n x m, where n = symbols count, m = states count, initialized with zeros.
  def init_transition_matrices
    self.transition_matrices = Array.new(symbols_list.count){Array.new(states_count){Array.new(states_count){0}}}
  end

  def self.generate_symbols_list(count)
    # generates a count - length array of symbols
    (0..count-1).map(&:to_s)
  end
end
