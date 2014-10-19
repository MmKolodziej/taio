require_relative'dfa_pso.rb'

class OCR_PSO < Rounded_PSO
  def initialize(symbols_list, states_count, images_filepath)
    @dfa = Automata.new(symbols_list, states_count, nil)
    #init images from filepath
  end

  def objective_function
    #for wektor_cech in obrazki
    #wektor_cech.normalizuj_i_zaokraglij
    #end_state =  automata.compute_word(wektor_cech)
    #if end_State != wektor_cech.moja_klasa
      #error_count +=1
  end
end

