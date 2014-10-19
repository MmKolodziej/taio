require_relative "pso.rb"
require_relative "automata.rb"

class DFA_PSO < PSO

  def initialize(symbols_list, states_count, accepting_states)
    @accepting_states = accepting_states
    @dfa = Automata.new(symbols_list, states_count, nil)
    #TODO: remove this later (parametrize or sth)
    @correct_words = ['0', '1000', '101111', '1', '1010111001', '1010101010101', '111']
    @incorrect_words = ['00', '01', '0101110', '01010101010', '000100010', '0000101010000101']
  end

  def objective_function(vector)
    errors_count = 0
    @dfa.set_transition_matrix_from_vector(vector) #TODO: implement this in automata class


    @correct_words.each do |word|
      if not @accepting_states.include? @dfa.compute_word(word)
        errors_count+=1
      end
    end
    @incorrect_words.each do |word|
      if @accepting_states.include? @dfa.compute_word(word)
        errors_count+=1
      end
    end

    return errors_count
  end

end


