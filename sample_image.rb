require 'csv'

class SampleImage
  NORMALIZATION_FACTORS = {
      factor0: {min: 0, max: 5},
      factor1: {min: -2, max: 2},
      factor2: {min: 0, max: 1},
      factor3: {min: 0, max: 1},
      factor4: {min: 0, max: 1},
  }

  attr_accessor :image_class, :filepath, :symbols_vector

  def initialize(filepath, image_class)
    self.image_class = image_class
    self.filepath = filepath
  end

  def map_factors(symbols_list)
    self.symbols_vector = initialize_symbols_vector(symbols_list)
  end

  def initialize_symbols_vector(symbols_list)
    coeficient_vector = CSV.read(self.filepath, col_sep: ';').flatten.map(&:to_f)
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

class ImageSample
  
  def initialize(values_vector, normalization_vector)
    self.image_class = Integer(values_vector[0])
    self.characteristics =[]
    
    values_vector.each_with_index do |val,index|
      if index > 0
        self.characteristics << val
      end
    end
    self.characteristics = ImageSample.normalize_vector(self.characteristics, normalization_vector)

    puts "created sample_image: #{self.image_class} , #{self.characteristics}"
  end

  attr_accessor :image_class, :characteristics, :word
  
  def self.get_rows_from_csv(filepath)
    # returns rows from the csv, converted to float arrays
    rows = []
    lines = []
    csv = CSV.read(filepath)
    csv.each { |row| rows << row[0].split(';') }

    rows.each do |row|
      lines << row.map(&:to_f)
    end
    lines
  end

  def self.create_multiple_from_csv(filepath)
    #returns array of sample images for each row of the csv
    # TODO: add errors handling
    sample_images =[]
    lines = ImageSample.get_rows_from_csv(filepath)

    # set the number of columns (dont count the first one which is the symbol's class indicator)
    nr_of_columns = (lines[0].count) -1
    max_columns = Array.new(nr_of_columns) { 0 }

    lines.each do |line|
      # update the max_columns vector
      line.each_with_index do |column, index|
        if index > 0 # the first column is the class marker
          if max_columns[index-1] < column
            max_columns[index-1] = column
          end
        end
      end
    end
    puts "max values vector is #{max_columns}"
    
    lines.each { |line| sample_images << ImageSample.new(line,max_columns)}
    puts "loaded #{sample_images.count} images"
    sample_images
  end
  
  def self.normalize_vector(vector, normalization_vector)
    vector.each_with_index.map do |val,index |
      val / normalization_vector[index]
    end
  end

  def print
    puts "Class: #{self.image_class}, characteristics: #{self.characteristics}"
  end

  def get_characteristics
    self.characteristics
  end

  def set_word(word)
    self.word = word
  end

  def get_word
    self.word
  end
end
