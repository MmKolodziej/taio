require_relative '../automata/fuzzy_automata'
require_relative '../pso/fuzzy_ocr_pso'
require_relative '../pso/non_det_ocr_pso'
require_relative '../image_generation/image_factory'
require_relative '../helpers/xlsx_doc'

ETAP_AUTOMAT_LIST = {
    "a1" => "automat deterministyczny bez elementow obcych",
    "a2" => "automat deterministyczny z elementami obcymi",
    "a3" => "automat niedeterministyczny bez elementow obcych",
    "a4" => "automat niedeterministyczny z elementami obcymi",
    "a5" => "automat rozmyty bez elementow obcych",
    "a6" => "automat rozmyty z elementami obcymi"
}
LEARNING_SET_FILEPATH = "learning.csv"
TEST_SET_FILEPATH = "test.csv"


def run_pso (etap, wejscieTyp, sciezkaTrain, sciezkaTest, sciezkaOutputKlas, sciezkaOutputErr, iloscKlas, iloscCech,
             iloscPowtorzenWKlasie, minLos, maxLos, procRozmTest, procRozmObce, procRozmZaburz, dyskretyzacja,
             ograniczNietermin, psoiter, psos, psok, psop, pso)

  puts "Etap #{etap}, #{ETAP_AUTOMAT_LIST[etap]}"

  if wejscieTyp == "gen"
    # generate data for the automata

    learn_set_filepath = LEARNING_SET_FILEPATH
    test_set_filepath = TEST_SET_FILEPATH

    ImageFactory.instance.generate_image_templates(iloscKlas, iloscCech, maxLos)
    no_foreign_elements = (iloscPowtorzenWKlasie * iloscKlas * procRozmObce).to_i
    ImageFactory.instance.generate_images_csv(iloscPowtorzenWKlasie, procRozmZaburz, LEARNING_SET_FILEPATH, no_foreign_elements)
    #TODO: load test data from part of the learning data
    ImageFactory.instance.generate_images_csv(iloscPowtorzenWKlasie, procRozmZaburz, TEST_SET_FILEPATH, no_foreign_elements)
  elsif wejscieTyp == "czyt"
    # read data from file
    learn_set_filepath = sciezkaTrain
    test_set_filepath = sciezkaTest
  end

  # pso initialization
  symbols_list = BaseAutomata.generate_symbols_list(dyskretyzacja)
  verbose = true


  case etap
    when "a1"
      pso = OcrPso.new(symbols_list, 0, learn_set_filepath, false, verbose)
      states_count = pso.states_count
      automata = FuzzyAutomata.new(symbols_list, pso.states_count, nil, [])
    when "a2"
      pso = OcrPso.new(symbols_list, 0, learn_set_filepath, true, verbose)
      states_count = pso.states_count
      automata = FuzzyAutomata.new(symbols_list, pso.states_count, nil, [states_count])
    when "a3"
      pso = NonDetOcrPso.new(symbols_list, 0, learn_set_filepath, false, ograniczNietermin, verbose)
      states_count = pso.states_count
      automata = FuzzyAutomata.new(symbols_list, pso.states_count, nil, [])
    when "a4"
      pso = NonDetOcrPso.new(symbols_list, 0, learn_set_filepath, true, ograniczNietermin, verbose)
      states_count = pso.states_count
      automata = FuzzyAutomata.new(symbols_list, pso.states_count, nil, [states_count])
    when "a5"
      pso = FuzzyOcrPso.new(symbols_list, 0, learn_set_filepath, false, verbose)
      states_count = pso.states_count
      automata = FuzzyAutomata.new(symbols_list, pso.states_count, nil, [])
    when "a6"
      pso = FuzzyOcrPso.new(symbols_list, 0, learn_set_filepath, true, verbose)
      states_count = pso.states_count
      automata = FuzzyAutomata.new(symbols_list, pso.states_count, nil, [states_count])
  end

  # algorithm configuration
  puts states_count

  if etap == "a1" || etap == "a2"
    # deterministic automata

    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { [0.0, states_count - 1] }
    max_vel = states_count / 10
  else
    problem_size = states_count * states_count * symbols_list.count
    search_space = Array.new(problem_size) { [0.0, 1.0] }
    max_vel = 0.05
  end

  vel_space = Array.new(problem_size) { [-max_vel, max_vel] }
  c1, c2 = 1.0, 1.0
  max_gens = psoiter
  pop_size = psos == 0 ? 10 + (2 * Math.sqrt(problem_size)).to_i : psos

  # Execute the algorithm
  best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
  learning_error = best[:cost].to_f/pso.images_count

  # OutputErr info
  puts "Blad na zbiorze treningowym: #{learning_error * 100.0}%"
  if sciezkaOutputErr != nil
    File.delete(sciezkaOutputErr) if File.exists?(sciezkaOutputErr)
    xlsx = XlsxDocWriter.new(sciezkaOutputErr)
    xlsx.add_cell(0, 0, learning_error)
    xlsx.write_to_file
  end

  # Test on test images
  test_set = OcrPso.create_words_from_image_vectors(ImageFactory.instance.load_sample_images_from_csv(test_set_filepath), symbols_list)
  puts 'Testing generated automata on test set...'
  errors_count = 0
  recognized_elements = []

  test_set.each do |image|
    end_states = automata.compute_word(image.word)
    error_val = 0
    case etap
      when "a1", "a2"
        error_val = 1 if end_states != image.image_class
      when "a3", "a4"
        if image.image_class == -1
          error_val = 1 if not a.is_in_rejecting_state?
        else
          error_val = 1 if not end_states[image.image_class] == 1
        end
      when "a5", "a6"
        error_val = FuzzyOcrPso.weighted_percentage_cost(end_states, image)
    end
    errors_count += error_val
    recognized_elements << image if error_val < 0.5
  end

  if sciezkaOutputKlas != nil
    File.delete(sciezkaOutputKlas) if File.exists?(sciezkaOutputKlas)
    xlsx = XlsxDocWriter.new(sciezkaOutputKlas)
    recognized_elements.each_with_index { |elem, index| xlsx.add_cell(index, 0, elem.image_class) }
    xlsx.write_to_file
  end

end
