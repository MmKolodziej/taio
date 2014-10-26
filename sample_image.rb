require 'csv'

class ImageSample

  def initialize(image_class, characteristics, normalization_min_max_values=nil)
    self.image_class = image_class
    self.characteristics = normalization_min_max_values ?
        ImageSample.normalize_vector(characteristics, normalization_min_max_values) :
        characteristics

    puts "created sample_image: #{self.image_class} , #{self.characteristics}"
  end

  attr_accessor :image_class, :characteristics, :word

  def self.get_rows_from_csv(filepath)
    # returns rows from the csv, converted to float arrays
    rows = []
    lines = []
    rows = CSV.read(filepath)

    rows.each do |row|
      lines << row.map(&:to_f)
    end
    lines
  end

  def self.create_multiple_from_csv(filepath)
    # returns array of sample images for each row of the csv
    # TODO: add errors handling
    sample_images =[]
    lines = ImageSample.get_rows_from_csv(filepath)

    # We assume that 0 is always the min value
    normalization_min_max_values = Hash.new {|h,k| h[k] = {min: 0, max: nil}}

    lines.each do |line|
      # update min and max values of the column
      line.each_with_index do |value, column_index|
        if column_index == 0 # the first column is the class marker
          next
        end
        current_col_min_max = normalization_min_max_values[column_index-1]

        if !current_col_min_max[:max] || value > current_col_min_max[:max]
          current_col_min_max[:max] = value
        end

        if !current_col_min_max[:min] || value < current_col_min_max[:min]
          current_col_min_max[:min] = value
        end
      end
    end
    puts "Min/max values dictionary is #{normalization_min_max_values}"

    lines.each { |line| sample_images << ImageSample.new(line[0].to_i, line[1..-1], normalization_min_max_values) }
    puts "loaded #{sample_images.count} images"
    sample_images
  end

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

class ImageSampleTemplate

  attr_accessor :image_class, :characteristics

  def initialize(image_class, characteristics_count, characteristic_max_value = 100.0)
    self.image_class = image_class
    self.characteristics = Array.new(characteristics_count) { rand(characteristic_max_value) }
  end

  def create_image_with_deviation(sigma)
    values = []
    characteristics.each { |val| values << val + 5*rand(sigma) } # TODO: change to gaussian
    ImageSample.new(image_class, values)
  end

  def print
    puts image_class characteristics
  end
end

class ImageSamplesGenerator
  #factory class

  attr_accessor :classes

  def generate_image_templates(no_of_classes, characteristics_count = 5, range_of_chars = 100.0)
    self.classes = Array.new(no_of_classes) { |i| ImageSampleTemplate.new(i, characteristics_count, range_of_chars) }
  end

  def generate_images(no_of_objects, sigma)
    images = []

    classes.each do |image_class|
      no_of_objects.times do
        images << image_class.create_image_with_deviation(sigma)
      end
    end
    puts "generated #{images.size} sample images with sigma = #{sigma}"
    images
  end

  def generate_images_csv(no_of_objects, sigma, filename = 'images.csv')
    images = generate_images(no_of_objects, sigma)

    CSV.open(filename, 'w') do |csv|
      images.each do |image|
        csv << [image.image_class].concat(image.characteristics)
      end
    end
  end
end