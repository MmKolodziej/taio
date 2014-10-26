require 'test/unit'
require_relative '../image_sample.rb'

class MyTest < Test::Unit::TestCase
  def setup
    self.csv_filename = 'images.csv'
  end
  attr_accessor :csv_filename
  def teardown

  end

  def test_image_generator
    # parameters
    no_of_classes = 10
    no_of_characteristics = 5
    no_of_objects = 20

    sigma = 0.2

    # init image classes
    gen = CsvImageFactory.new()
    gen.generate_image_templates(no_of_classes, no_of_characteristics)

    # factory method test
    images = gen.generate_test_images(no_of_objects, sigma)
    assert_equal(no_of_objects*no_of_classes, images.size)

    # csv generator functionality test
    gen.generate_images_csv(no_of_objects, sigma, csv_filename)
    assert_equal(no_of_objects*no_of_classes, CSV.open(csv_filename,'r').count)
  end

end