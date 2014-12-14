require_relative '../automata/fuzzy_automata'
require_relative '../pso/fuzzy_ocr_pso'
require_relative '../pso/non_det_ocr_pso'
require_relative '../image_generation/csv_image_factory'

ETAP_AUTOMAT_LIST = {
    "a1" => "automat deterministyczny bez elementow obcych",
    "a2" => "automat deterministyczny z elementami obcymi",
    "a3" => "automat niedeterministyczny bez elementow obcych",
    "a4" => "automat niedeterministyczny z elementami obcymi",
    "a5" => "automat rozmyty bez elementow obcych",
    "a6" => "automat rozmyty z elementami obcymi"
}
LEARNING_SET_FILEPATH = 'learning.csv'
TEST_SET_FILEPATH = 'test.csv'


def run_pso (etap, wejscieTyp, sciezkaTrain, sciezkaTest, sciezkaOutputKlas, sciezkaOutputErr, iloscKlas, iloscCech,
             iloscPowtorzenWKlasie, minLos, maxLos, procRozmTest, procRozmObce, procRozmZaburz, dyskretyzacja,
             ograniczNietermin, psoiter, psos, psok, psop, pso)

  puts "Etap #{etap}, #{ETAP_AUTOMAT_LIST[:etap]}"

  if wejscieTyp == "gen"
    # generate data for the automata

    CsvImageFactory.instance.generate_image_templates(iloscKlas, iloscCech, maxLos)
    no_foreign_elements = (iloscPowtorzenWKlasie * iloscKlas * procRozmObce).to_i
    CsvImageFactory.instance.generate_images_csv(iloscPowtorzenWKlasie, procRozmZaburz, LEARNING_SET_FILEPATH, no_foreign_elements)
    #TODO: load test data from part of the learning data
    CsvImageFactory.instance.generate_images_csv(iloscPowtorzenWKlasie, procRozmZaburz, TEST_SET_FILEPATH, no_foreign_elements)

    learn_set_filepath = LEARNING_SET_FILEPATH
    test_set_filepath = TEST_SET_FILEPATH
  elsif wejscieTyp == "czyt"
    # read data from file
    learn_set_filepath = sciezkaTrain
    test_set_filepath = sciezkaTest
  end

  # pso initialization
  symbols_list = BaseAutomata.generate_symbols_list(dyskretyzacja)
  verbose = true
  # TODO: handle rejecting_states index
  rejecting_states = []


  case etap
    when "a1"
      pso = OcrPso.new(symbols_list, 0, learn_set_filepath, nil, verbose)
    when "a2"
      pso = OcrPso.new(symbols_list, 0, learn_set_filepath, rejecting_states, verbose)
    when "a3"
      #TODO: ograniczenie niedeterminnizmu
      pso = NonDetOcrPso.new(symbols_list, 0, learn_set_filepath, ograniczNietermin, nil, verbose)
    when "a4"
      pso = NonDetOcrPso.new(symbols_list, 0, learn_set_filepath, ograniczNietermin, rejecting_states, verbose)
    when "a5"
      pso = FuzzyOcrPso.new(symbols_list, 0, learn_set_filepath, nil, verbose)
    when "a6"
      pso = FuzzyOcrPso.new(symbols_list, 0, learn_set_filepath, rejecting_states, verbose)
  end

  # algorithm configuration
  states_count = pso.states_count

  if etap == "a1" || etap == "a2"
    # deterministic automata

    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { [0.0, states_count - 1] }
    max_vel = states_count / 10
  else
    problem_size = states_count * states_count * symbols_list.count
    search_space = Array.new(problem_size) { [0.0, 1.0]}
    max_vel = 0.05
  end

  vel_space = Array.new(problem_size) { [-max_vel, max_vel]}
  c1, c2 = 1.0, 1.0
  max_gens = psoiter
  pop_size = psos == 0 ? 10 + (2 * Math.sqrt(problem_size)).to_i : psos

  # Execute the algorithm
  best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)

end
