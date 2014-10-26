class ImageSampleTemplate

  attr_accessor :image_class, :ideal_characteristics, :characteristic_max_value

  def initialize(image_class, characteristics_count, characteristic_max_value = 100.0)
    self.image_class = image_class
    self.characteristic_max_value = characteristic_max_value
    self.ideal_characteristics = Array.new(characteristics_count) { rand(characteristic_max_value) }
  end

  def print
    puts image_class ideal_characteristics
  end
end
