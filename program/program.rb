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


def run_pso (etap, wejscieTyp, sciezkaTrain, sciezkaTest, sciezkaObceTrain, sciezkaObceTest, sciezkaOutputKlas, sciezkaOutputErr, iloscKlas, iloscCech,
             iloscPowtorzenWKlasie, minLos, maxLos, procRozmTest, procRozmObce, zaburzenie, dyskretyzacja,
             ograniczNietermin, psoiter, psos, psocp, psocg, psostagnate, vmax)

  puts "Etap #{etap}, #{ETAP_AUTOMAT_LIST[etap]}"

  if wejscieTyp == "gen"
    # generate data for the automata

    learn_set_filepath = etap + "_" + LEARNING_SET_FILEPATH
    test_set_filepath = etap + "_" + TEST_SET_FILEPATH
    begin
      File.delete(learn_set_filepath) if File.exists?(learn_set_filepath)
      File.delete(test_set_filepath) if File.exists?(test_set_filepath)

      ImageFactory.instance.generate_image_templates(iloscKlas, iloscCech, maxLos)
      no_learning_images = iloscPowtorzenWKlasie * (100 - procRozmTest) / 100
      no_foreign_elements = (no_learning_images * (iloscKlas + 1) * procRozmObce / 100).to_i
      ImageFactory.instance.generate_images_csv(no_learning_images, zaburzenie, learn_set_filepath, no_foreign_elements)

      no_test_images = iloscPowtorzenWKlasie * procRozmTest / 100
      no_foreign_elements = (no_test_images * (iloscKlas + 1) * procRozmObce / 100).to_i
      ImageFactory.instance.generate_images_csv(no_test_images, zaburzenie, test_set_filepath, no_foreign_elements)

    rescue Exception
      puts $!
      exit 1
    end

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
      automata = DeterministicAutomata.new(symbols_list, pso.states_count, nil, [])
    when "a2"
      pso = OcrPso.new(symbols_list, 0, learn_set_filepath, true, verbose)
      states_count = pso.states_count
      automata = DeterministicAutomata.new(symbols_list, pso.states_count, nil, [states_count])
    when "a3"
      pso = NonDetOcrPso.new(symbols_list, 0, learn_set_filepath, false, ograniczNietermin, verbose)
      states_count = pso.states_count
      automata = NonDeterministicAutomata.new(symbols_list, pso.states_count, nil, ograniczNietermin, [])
    when "a4"
      pso = NonDetOcrPso.new(symbols_list, 0, learn_set_filepath, true, ograniczNietermin, verbose)
      states_count = pso.states_count
      automata = NonDeterministicAutomata.new(symbols_list, pso.states_count, nil, ograniczNietermin, [states_count])
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
  puts "Learning set contains #{pso.images_count} elements"

  if etap == "a1" || etap == "a2"
    # deterministic automata

    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { [0.0, states_count - 1.0] }
    max_vel = vmax == 0 ? states_count / 8.0 : vmax
  else
    problem_size = states_count * states_count * symbols_list.count
    search_space = Array.new(problem_size) { [0.0, 1.0] }
    max_vel = vmax == 0 ? 0.05 : vmax
  end

  vel_space = Array.new(problem_size) { [-max_vel, max_vel] }
  c1 = psocp == 0 ? 1.0 : psocp
  c2 = psocg == 0 ? 1.0 : psocg
  max_gens = psoiter
  pop_size = psos == 0 ? 10 + (2 * Math.sqrt(problem_size)).to_i : psos

  puts "swarm_size = #{pop_size}, max_iter = #{psoiter}"

  # Execute the algorithm
  best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
  learning_error = best[:cost].to_f/pso.images_count

  # OutputErr info
  puts "Blad na zbiorze treningowym: #{learning_error * 100.0}%"
  if sciezkaOutputErr != nil
    begin
      File.delete(sciezkaOutputErr) if File.exists?(sciezkaOutputErr)
      xlsx = XlsxDocWriter.new(sciezkaOutputErr)
      xlsx.add_cell(0, 0, learning_error)
      xlsx.write_to_file
    rescue Exception
      puts $!
    end
  end

  if sciezkaTest != nil
    # Test on test images
    test_set = OcrPso.create_words_from_image_vectors(ImageFactory.instance.load_sample_images_from_csv(test_set_filepath), symbols_list)
    puts 'Testing generated automata on test set...'
    errors_count = 0
    recognized_elements = []
    automata.set_transition_matrices_from_vector(best[:position])

    test_set.each do |image|
      end_states = automata.compute_word(image.word)
      error_val = 0
      case etap
        when "a1", "a2"
          error_val = 1 if end_states != image.image_class
        when "a3"
          error_val = 1
          error_val -= end_states[image.image_class].to_f / end_states.inject(:+) if end_states[image.image_class] == 1
        when "a4"
          if image.image_class == -1
            error_val = 1 if not automata.is_in_rejecting_state?
          else
            error_val = 1
            error_val -= end_states[image.image_class].to_f / end_states.inject(:+) if end_states[image.image_class] == 1
          end
        when "a5", "a6"
          error_val = FuzzyOcrPso.weighted_percentage_cost(end_states, image.image_class)
      end
      errors_count += error_val
      recognized_elements << image if error_val <= 0.5
    end

    if sciezkaOutputKlas != nil
      begin
        File.delete(sciezkaOutputKlas) if File.exists?(sciezkaOutputKlas)
        xlsx = XlsxDocWriter.new(sciezkaOutputKlas)
        recognized_elements.each_with_index do |elem, index|
          xlsx.add_cell(index, 0, elem.image_class)
          xlsx.add_cell(index, 1, elem.word)
        end
        xlsx.write_to_file
      rescue Exception
        puts $!
      end
    end
    puts "Blad na zbiorze testowym: #{errors_count * 100.0 / test_set.count}"
  end

  learning_error
end
