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
      init_transition_matrix()
    end
  end

  #Computes a single symbol -> changes the automata's current state to the appropriate one.
  # symbol: the symbol to be computed (eg.: '0', 'a', 'X')
  def compute_symbol(symbol)
    transition_matrix[symbol][current_state]
  end

  # word: a list of symbols for the automata to compute (eg.: 'aabccaaa')
  # returns: End state if computations successful, False if word does not belong to automata alphabet
  def compute_word(word)
    if not is_word_from_alphabet(word)
      return nil
    end

    word.each_char do |symbol|
      self.current_state = compute_symbol(symbol)
    end

    end_state = current_state

    #reset the current_state for future computations
    self.current_state = 0

    return end_state
  end


  def is_word_from_alphabet(word)
    word.each_char { |symbol| return false if not symbols_list.include? symbol }

    return true
  end

  def print_transition_matrix
    symbols_list.each do |symbol|
      puts "Transition matrix[#{symbol}] = #{transition_matrix[symbol]}"
    end
  end

  private

  attr_accessor :symbols_list, :states_count, :current_state, :transition_matrix

  # returns: Matrix n x m, where n = symbols count, m = states count, initialized with zeros.
  def init_transition_matrix
    self.transition_matrix = []

    symbols_list.each do |symbol|
      transition_matrix << {symbol => []}
      (1..states_count).each do |i|
        transition_matrix[symbol] << 0
      end
    end
  end
end