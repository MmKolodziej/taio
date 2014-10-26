require 'csv'
require_relative 'random_gaussian'

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

class ImageFactory
  #factory class

  attr_accessor :template_images

  def generate_image_templates(no_of_classes, characteristics_count = 5, range_of_chars = 100.0)
    self.template_images = Array.new(no_of_classes) { |i| ImageSampleTemplate.new(i, characteristics_count, range_of_chars) }
  end

  def generate_test_images(images_count, sigma)
    images = []

    template_images.each do |template|
      images_count.times do
        images << create_sample_image_from_template(template, sigma)
      end
    end
    puts "generated #{images.size} sample images with sigma = #{sigma}"
    images
  end

  def generate_images_csv(no_of_objects, sigma, filename = 'images.csv')
    images = generate_test_images(no_of_objects, sigma)

    CSV.open(filename, 'w') do |csv|
      images.each do |image|
        csv << [image.image_class].concat(image.characteristics)
      end
    end
  end

  private

  # randomly generates an image from template (random values are normally distributed with mean = characetristic , deviation = sigma)
  def create_sample_image_from_template(image_template, sigma)
    random_characteristics = image_template.ideal_characteristics.map do |val|
      deviated = RandomGaussian.new(val, sigma).rand
      deviated = 0.0 if deviated < 0
      deviated = image_template.characteristic_max_value if deviated > 100
      deviated
    end
    # values = image_template.ideal_characteristics.each { |val| values << val + 5*rand(sigma) }
    ImageSample.new(image_template.image_class, random_characteristics)
  end
end