require 'csv'

class SampleImage
  NORMALIZATION_FACTORS = {
    factor0: { min: 0, max: 5 },
    factor1: { min: -2, max: 2 },
    factor2: { min: 0, max: 1 },
    factor3: { min: 0, max: 1 },
    factor4: { min: 0, max: 1 },
  }

  attr_accessor :name, :filepath, :symbols_vector

  def initialize(filepath, name)
    self.name = name
    self.filepath = filepath
  end

  def map_factors(symbols_list)
    self.symbols_vector = initialize_symbols_vector(filepath, symbols_list)
  end

  def initialize_symbols_vector(filepath, symbols_list)
    coeficient_vector = CSV.read(filepath, col_sep: ';').flatten.map(&:to_f)
    create_symbols_vector(symbols_list, normalize(coeficient_vector))
  end

  def normalize(vector)
    vector.each_with_index.map do |val, index|
      current_factor_constants = NORMALIZATION_FACTORS["factor#{index}".to_sym]
      (val - current_factor_constants[:min]).to_f / (current_factor_constants[:max] - current_factor_constants[:min])
    end
  end

  def create_symbols_vector(symbols_list, normalized_vector)
    symbols_vector = []
    range_size = 1.to_f/symbols_list.size
    normalized_vector.each do |coeficient|
      symbol_index = (coeficient / range_size).to_i
      symbols_vector << symbols_list[symbol_index]
    end

    symbols_vector
  end
end