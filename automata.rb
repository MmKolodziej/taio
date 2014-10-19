class Automata

  #symbols_list: list of symbols that the automata can process (eg.: '0,1' , 'a,b,c' etc)
  def initialize(symbols_list, states_count, transition_matrix)
    if (symbols_list.uniq.count != symbols_list.count)
      puts "Symbols: #{symbols_list} are not unique!"
    end

    self.symbols_list = symbols_list
    self.states_count = states_count
    self.current_state = 0

    if transition_matrix
      self.transition_matrix = transition_matrix
    else
      init_transition_matrix
    end
  end

  # Computes a single symbol -> changes the automata's current state to the appropriate one.
  # symbol: the symbol to be computed (eg.: '0', 'a', 'X')
  def compute_symbol(symbol)
    transition_matrix[symbols_list.index(symbol)][current_state]
  end

  # word: a list of symbols for the automata to compute (eg.: 'aabccaaa')
  # returns: End state if computations successfull, False if word does not belong to automata alphabet
  def compute_word(word)
    return unless word_is_from_alphabet?(word)

    word.each_char do |symbol|
      self.current_state = compute_symbol(symbol)
    end

    end_state = current_state

    # reset the current_state for future computations
    self.current_state = 0

    end_state
  end

  def word_is_from_alphabet?(word)
    word.each_char do |symbol|
      return false unless symbols_list.include?(symbol)
    end

    true
  end

  def print_transition_matrix
    symbols_list.each do |symbol|
      puts "Transition matrix[#{symbol}] = #{transition_matrix[symbols_list.index(symbol)]}"
    end
  end

  def set_transition_matrix_from_vector(vector)
    row_index, col_index = 0, 0

    while row_index < symbols_list.count
      while col_index < states_count
        vector_index = row_index * states_count + col_index
        transition_matrix[row_index][col_index] = Integer(vector[vector_index])
        col_index += 1
      end

      row_index += 1
      col_index = 0
    end
  end

  private

  attr_accessor :symbols_list, :states_count, :current_state, :transition_matrix

  # returns: Matrix n x m, where n = symbols count, m = states count, initialized with zeros.
  def init_transition_matrix
    self.transition_matrix = []

    symbols_list.each do |symbol|
      transition_matrix << []
      states_count.times do
        transition_matrix[symbols_list.index(symbol)] << 0
      end
    end
  end
end