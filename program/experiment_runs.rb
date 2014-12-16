require_relative 'program'

header = ['Run Date', 'Duration', 'Result', 'Elements Count', 'Classes Count', 'Symbols Count', 'Sigma', 'Iterations Count',
          'Foreign Elements Count', 'Non-Det Count', 'Swarmsize', 'c.p', 'c.g']

etap = "a1"
wejscieTyp = "gen" # "czyt"
sciezkaTrain = '..jastrzebska/Native.xlsx'
sciezkaTest = sciezkaTrain
sciezkaObceTrain = nil
sciezkaObceTest = nil
sciezkaOutputKlas = 'output_klas.xlsx'
sciezkaOutputErr = 'output_err.xlsx'
iloscKlas = 10
iloscCech = 5
iloscPowtorzenWKlasie = 20
minLos = 0
maxLos = 20
procRozmTest = 20
procRozmObce = 20
zaburzenie = 0.2
dyskretyzacja = 12
ograniczNietermin = 3
psoiter = 1000
psos = 0 # swarmsize
psocp = 0
psocg = 0
psostagnate = 0
vmax = 0

["a1", "a2", "a5", "a6"].each do |stage|
  etap = stage
  ograniczNietermin = 0

  elements_path = 'C:/Users/Alek/Desktop/Nowy folder/git/taio/taio/experiments/learning_sets/' + etap + '.csv'
  results_path = 'C:/Users/Alek/Desktop/Nowy folder/git/taio/taio/experiments/results/' + etap + '.xlsx'

  File.delete(results_path) if File.exists?(results_path)
  xlsx = XlsxDocWriter.new(results_path)
  xlsx.add_row(0, header)
  iteration_nr = 1

  [10, 20, 30].each do |elem_count|
    iloscPowtorzenWKlasie = elem_count
    [6, 8, 10].each do |classes_count|
      iloscKlas = classes_count
      [4, 6, 8, 10].each do |symbols_count|
        dyskretyzacja = symbols_count
        [0.05, 0.1, 0.2, 0.25].each do |sigma|
          zaburzenie = sigma
          [200, 500, 1000].each do |iterations_count|
            psoiter = iterations_count
            [0, 10, 20, 40].each do |foreign_count|
              procRozmObce = foreign_count
              [0, 0, 5, 10, 20].each do |swarmsize|
                psos = swarmsize
                [1.0, 1.5, 2.0].each do |c1|
                  psocp = c1
                  [1.0, 1.5, 2.0].each do |c2|
                    psocg = c2

                    ImageFactory.instance.generate_image_templates(iloscKlas, iloscCech, maxLos)
                    no_foreign_elements = (iloscPowtorzenWKlasie * (iloscKlas + 1) * procRozmObce / 100).to_i
                    ImageFactory.instance.generate_images_csv(iloscPowtorzenWKlasie, zaburzenie, elements_path, no_foreign_elements)

                    start_time = Time.now
                    result = run_pso(etap, "czyt", elements_path, sciezkaTest = nil, sciezkaObceTrain = nil, sciezkaObceTest = nil,
                                     sciezkaOutputKlas = nil, sciezkaOutputErr = nil,
                                     iloscKlas, iloscCech, iloscPowtorzenWKlasie, minLos, maxLos, procRozmTest, procRozmObce,
                                     zaburzenie, dyskretyzacja, ograniczNietermin,
                                     psoiter, psos, psocp, psocg, psostagnate, vmax
                    )
                    end_time = Time.now
                    duration = end_time.to_i - start_time.to_i
# save the results to file
                    info_row = [
                        Time.now.to_s, duration, result, iloscPowtorzenWKlasie, iloscKlas, dyskretyzacja, zaburzenie, psoiter,
                        procRozmObce, ograniczNietermin, swarmsize, c1, c2
                    ]
                    xlsx.add_row(iteration_nr, info_row)
                    iteration_nr += 1
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end