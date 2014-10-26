require 'test/unit'
require_relative '../random_gaussian'

class RandomGaussianTest < Test::Unit::TestCase
  def test_random
    random_gaussian = RandomGaussian.new(5, 0.2)
    array = Array.new(100) {|i| random_gaussian.rand}
    puts array
    array.each do |val|
      assert_in_delta(4,val,6)
    end
  end
end