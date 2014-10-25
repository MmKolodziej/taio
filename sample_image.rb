require 'csv'

class ImageSample

  def initialize(image_class, values_vector, normalization_vector=nil)
    self.image_class = image_class
    self.characteristics = values_vector

    if normalization_vector
      self.characteristics = ImageSample.normalize_vector(self.characteristics, normalization_vector)
    end

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

    lines.each { |line| sample_images << ImageSample.new(line[0].to_i, line[1..-1], max_columns) }
    puts "loaded #{sample_images.count} images"
    sample_images
  end

  def self.normalize_vector(vector, normalization_vector)
    vector.each_with_index.map do |val, index|
      val / normalization_vector[index]
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

  def initialize(image_class, no_of_characteristics, range_of_chars = 100)
    self.image_class = image_class
    self.characteristics = Array.new(no_of_characteristics) { rand(range_of_chars) }
  end

  attr_accessor :image_class, :characteristics

  def create_image_with_deviation(sigma)
    values = []
    characteristics.each { |char| values << char + 5*rand(sigma) } # TODO: change to gaussian
    ImageSample.new(image_class, values)
  end

  def print
    puts image_class characteristics
  end
end

class ImageSamplesGenerator
  #factory class

  attr_accessor :classes

  def generate_image_samples(no_of_classes, no_of_characteristics = 5, range_of_chars = 100)
    self.classes = Array.new(no_of_classes) { |i| ImageSampleTemplate.new(i, no_of_characteristics, range_of_chars) }
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