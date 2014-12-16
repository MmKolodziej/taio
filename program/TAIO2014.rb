require_relative 'program'


# default values
etap = nil
wejscieTyp = nil
sciezkaTrain = nil
sciezkaTest = nil
sciezkaObceTrain = nil
sciezkaObceTest = nil
sciezkaOutputKlas = 'output_klas.xlsx'
sciezkaOutputErr = 'output_err.xlsx'
iloscKlas = 10
iloscCech = 5
iloscPowtorzenWKlasie = 10
minLos = 0
maxLos = 20
procRozmTest = 20
procRozmObce = 0
zaburzenie = 0.2
dyskretyzacja = 12
ograniczNietermin = 3
psoiter = 1000
psos = 0
psok = nil
psop = nil
pso = nil


pso_arguments = {}
i = 0
begin
  if i >= ARGV.count - 1
    puts "Wrong arguments format! (are you missing a value after argument name?)"
    exit 1
  end
  if ARGV[i] != nil and ARGV[i][0] != "-"
    puts "Wrong arguments format (#{i+1}th element)! (are you missing a '-' ?)"
    exit 1
  end

  val = ARGV[i + 1]
  case ARGV[i][1..-1].downcase
    when "etap"
      etap = val
    when "wejscietyp"
      wejscieTyp = val
    when "sciezkatrain"
      sciezkaTrain = val
    when "sciezkatest"
      sciezkaTest = val
    when "sciezkaobcetrain"
      sciezkaObceTrain = val
    when "sciezkaobcetest"
      sciezkaObceTest = val
    when "sciezkaoutputklas"
      sciezkaOutputKlas = val
    when "sciezkaoutputerr"
      sciezkaOutputErr = val
    when "iloscklas"
      iloscKlas = val.to_i
    when "ilosccech"
      iloscCech = val.to_i
    when "iloscpowtorzenwklasie"
      iloscPowtorzenWKlasie = val.to_i
    when "minlos"
      minLos = val.to_f
    when "maxlos"
      maxLos = val.to_f
    when "procrozmtest"
      procRozmTest = val.to_i
    when "procrozmobce"
      procRozmObce = val.to_i
    when "zaburzenie"
      zaburzenie = val.to_f
    when "dyskretyzacja"
      dyskretyzacja = val.to_i
    when "ogranicznieterm"
      ograniczNietermin = val.to_i
    when "psoiter"
      psoiter = val.to_i
    when "psos"
      psos = val.to_i

    else
      puts "Unknown argument: #{ARGV[i]}"
      exit 1
  end
  pso_arguments[ARGV[i][1..-1]] = val

  i += 2
end while i < ARGV.count

puts
puts pso_arguments.inspect

run_pso(etap, wejscieTyp, sciezkaTrain, sciezkaTest, sciezkaObceTrain, sciezkaObceTest, sciezkaOutputKlas, sciezkaOutputErr,
        iloscKlas, iloscCech, iloscPowtorzenWKlasie, minLos, maxLos, procRozmTest, procRozmObce, zaburzenie,
        dyskretyzacja, ograniczNietermin, psoiter, psos, psok, psop, pso
)


