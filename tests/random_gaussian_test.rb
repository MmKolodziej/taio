require 'test/unit'
require_relative '../random_gaussian'

class RandomGaussianTest < Test::Unit::TestCase
  def test_random
    random_gaussian = RandomGaussian.new(0, 0.2)
    array = Array.new(10) {|i| random_gaussian.rand}

    puts 'done'
  end
end