class Automata

  #symbols_list: list of symbols that the automata can process (eg.: '0,1' , 'a,b,c' etc)
  def initialize(symbols_list, states_count)
    if (symbols_list.uniq.count != symbols_list.count)
      puts "Symbols: #{symbols_list} are not unique!"
    end

    self.symbols_list = symbols_list
    self.states_count = states_count
    self.current_state = 0
    init_transition_lists
  end

  # returns: Matrix n x m, where n = symbols count, m = states count, initialized with zeros.
  def compute_symbol(symbol)

  end

  def compute_word(word)

  end


  def is_word_from_alphabet(word)
    word.each_char { |symbol| return false if not symbols_list.include? symbol }

    return true
  end
  private

  attr_accessor :symbols_list, :states_count, :current_state, :transition_lists

  def init_transition_lists
    transition_lists = []

    symbols_list.each do |symbol|
      transition_lists << []
      (1..states_count).each do |i|
        transition_lists[symbols_list.index(symbol)] << 0
      end
    end
  end

  def print_transition_list
    symbols_list.each { |symbol| puts "Transition list[#{symbol}] = #{transition_lists[symbols_list.index(symbol)]}" }
  end
end

automata = Automata.new(['a', 'b', 'c', 'd'], 3)

puts "#{automata.is_word_from_alphabet("baba")}"