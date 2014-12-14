class ImageSampleTemplate

  attr_accessor :image_class, :ideal_characteristics, :characteristic_max_values, :characteristic_min_values

  def initialize(image_class, characteristics_count, characteristic_min_value = 0.0, characteristic_max_value = 100.0)
    self.image_class = image_class
    self.characteristic_max_values = Array.new(characteristics_count){characteristic_max_value}
    self.characteristic_min_values = Array.new(characteristics_count){characteristic_min_value}
    self.ideal_characteristics = Array.new(characteristics_count) { rand(characteristic_max_value).to_f + characteristic_min_value}
  end

  def normalize(max_val = nil)
    self.characteristic_max_values = max_val ? max_val : self.characteristic_max_values
    self.ideal_characteristics = self.ideal_characteristics.each_with_index.map { |val,index | val/(self.characteristic_max_values[index] - self.characteristic_min_values[index]) + characteristic_min_values[index]}
  end

  def print
    puts image_class ideal_characteristics
  end
end
