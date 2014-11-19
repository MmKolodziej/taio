class BaseAutomata

  def self.generate_symbols_list(count)
    # generates a count - length array of symbols
    (0..count-1).map(&:to_s)
  end

  def initialize(symbols_list, states_count, transition_matrices=nil, rejecting_states = [])
    if (symbols_list.uniq.count != symbols_list.count)
      puts "Symbols: #{symbols_list} are not unique!"
    end

    self.symbols_list = symbols_list
    self.states_count = states_count

    if transition_matrices
      self.transition_matrices = transition_matrices
    else
      init_transition_matrices
    end

    self.rejecting_states = rejecting_states
  end

  def print_transition_matrix
    symbols_list.each do |symbol|
      puts "Transition matrix[#{symbol}] = "
      transition_matrices[symbols_list.index(symbol)].each { |row| puts row.inspect }
    end
  end

  protected

  attr_accessor :symbols_list, :states_count, :transition_matrices, :rejecting_states

  def word_is_from_alphabet?(word)
    word.each do |symbol|
      return false unless symbols_list.include?(symbol)
    end

    true
  end

  private
  # returns: Matrix n x m, where n = symbols count, m = states count, initialized with zeros.
  def init_transition_matrices
    self.transition_matrices = Array.new(symbols_list.count){Array.new(states_count){Array.new(states_count){0}}}
  end
end