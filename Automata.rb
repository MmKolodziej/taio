class Automata

  #symbols_list: list of symbols that the automata can process (eg.: '0,1' , 'a,b,c' etc)
  def initialize(symbols_list, states_count)
    self.symbols_list = symbols_list
    self.states_count = states_count
  end

  def compute_symbol(symbol)

  end

  def compute_word(word)

  end

  private

  attr_accessor :symbols_list, :states_count

  def init_transition_lists

  end


  def is_word_from_alphabet(word)

  end
end