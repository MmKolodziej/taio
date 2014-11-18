require_relative 'sample_image_template'
require_relative '../helpers/random_gaussian'
require_relative 'image_sample'

# Generates, loads and saves images from and to CSV
class CsvImageFactory
  @@instance = CsvImageFactory.new

  attr_accessor :template_images, :characteristics_count, :range

  def self.instance
    return @@instance
  end

  def generate_image_templates(no_of_classes, characteristics_count = 5, range_of_chars = 100.0)
    self.characteristics_count = characteristics_count
    self.template_images = Array.new(no_of_classes) { |i| ImageSampleTemplate.new(i, characteristics_count, range_of_chars) }
    max_vector = Array.new(characteristics_count) {0}
    self.template_images.each do |template|
      template.ideal_characteristics.each_with_index { |val, index | max_vector[index] = val if max_vector[index] < val }
    end
    self.template_images.each { |template| template.normalize(max_vector) }
  end

  def generate_test_images(images_count, sigma)
    images = []

    template_images.each do |template|
      images_count.times do
        images << create_sample_image_from_template(template, sigma)
      end
    end
    #puts "generated #{images.size} sample images with sigma = #{sigma}"
    images
  end

  def generate_images_csv(no_of_objects, sigma, filename = 'images.csv', no_of_alien_elements = 0)
    images = generate_test_images(no_of_objects, sigma)
    images.concat(generate_alien_elements(no_of_alien_elements))

    CSV.open(filename, 'w') do |csv|
      images.each do |image|
        csv << [image.image_class].concat(image.characteristics)
      end
    end
  end

  def load_sample_images_from_csv(filepath)
    # returns array of sample images for each row of the csv
    # TODO: add errors handling
    sample_images = []
    lines = CSV.read(filepath).map { |row| row.map(&:to_f)}

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
    #puts "Min/max values dictionary is #{normalization_min_max_values}"

    lines.each { |line| sample_images << ImageSample.new(line[0].to_i, line[1..-1], normalization_min_max_values) }
    #puts "loaded #{sample_images.count} images"
    sample_images
  end

  private_class_method :new

  private

  # randomly generates an image from template (random values are normally distributed with mean = characetristic , deviation = sigma)
  def create_sample_image_from_template(image_template, sigma)
    random_characteristics = image_template.ideal_characteristics.map do |val|
      deviated = RandomGaussian.new(val, sigma).rand
      deviated = 0.0 if deviated < 0
      deviated = 1 if deviated > 1
      deviated
    end
    # values = image_template.ideal_characteristics.each { |val| values << val + 5*rand(sigma) }
    ImageSample.new(image_template.image_class, random_characteristics)
  end

  def generate_alien_elements(no_of_elements)
    alien_elements = []

    no_of_elements.times do
      alien_elements << ImageSample.new(ImageSample::ALIEN_ELEMENTS_CLASS, Array.new(characteristics_count){rand})
    end
    alien_elements
  end
end
