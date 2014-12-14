etap_automat_list = {
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
             iloscPowtorzenWKlasie, minLos, maxLos,  zaburzenie, procRozmTest, procRozmObce, procRozmZaburz, dyskretyzacja,
             ograniczNietermin, psoiter, psos, psok, psop, pso)

  puts "Etap #{etap}, #{etap_automat_list[:etap]}"

  if wejscieTyp == "gen"
    # generate data for the automata

    ImageFactory.instance.generate_image_templates(iloscKlas, iloscCech, maxLos)
    no_foreign_elements = (iloscPowtorzenWKlasie * iloscKlas * procRozmObce).to_i
    ImageFactory.instance.generate_images_csv(iloscPowtorzenWKlasie, zaburzenie, LEARNING_SET_FILEPATH, no_foreign_elements)
    #TODO: load test data from part of the learning data
    ImageFactory.instance.generate_images_csv(iloscPowtorzenWKlasie, zaburzenie, TEST_SET_FILEPATH, no_foreign_elements)
  elsif wejscieTyp == "czyt"
    # read data from file
  end



end
