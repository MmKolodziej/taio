require 'csv'
require_relative 'random_gaussian'

class ImageSample

  def initialize(image_class, characteristics, normalization_min_max_values=nil)
    self.image_class = image_class
    self.characteristics = normalization_min_max_values ?
        ImageSample.normalize_vector(characteristics, normalization_min_max_values) :
        characteristics

    #puts "created sample_image: #{self.image_class} , #{self.characteristics}"
  end

  attr_accessor :image_class, :characteristics, :word

  def self.normalize_vector(vector, normalization_min_max_values)
    vector.each_with_index.map do |val, index|
      current_min_max = normalization_min_max_values[index]
      (val - current_min_max[:min]) / (current_min_max[:max] - current_min_max[:min])
    end
  end

  def print
    puts "Class: #{self.image_class}, characteristics: #{self.characteristics}"
  end

  def print_as_csv_row

  end

  def get_characteristics
    self.characteristics
  end

  def set_word(word)
    self.word = word
  end

end