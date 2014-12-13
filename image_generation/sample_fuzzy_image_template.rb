class FuzzyImageSampleTemplate

  attr_accessor :image_classes, :ideal_characteristics, :characteristic_max_value

  def initialize(image_classes, characteristics_count, symbols_count, characteristic_max_value = 1.0)
    self.image_classes = image_classes
    self.characteristic_max_value = characteristic_max_value
    self.ideal_characteristics = Array.new(characteristics_count) { compute_characteristics_values(symbols_count) }
  end

  def compute_characteristics_values( symbols_count)
    main_characteristic_symbol = rand(symbols_count)
    characteristics = Array.new(symbols_count) { 0 }

    shift = rand * 2 - 1 # rand[-1, 1]

    characteristics[main_characteristic_symbol] = characteristic_value_function(0, shift)
    if main_characteristic_symbol > 0
      characteristics[main_characteristic_symbol - 1] = characteristic_value_function(-1, shift)
    end
    if main_characteristic_symbol < symbols_count - 1
      characteristics[main_characteristic_symbol + 1] = characteristic_value_function(1, shift)
    end
    characteristics
  end

  def characteristic_value_function(symbol_index, shift)
    val = - 0.9 * (symbol_index + shift).abs + 1
    val > 0 ? val : 0
  end

  def print
    puts image_classes ideal_characteristics
  end
end

