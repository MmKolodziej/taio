require 'test/unit'
require_relative '../pso.rb'

class MyTest < Test::Unit::TestCase

  def test_integer_search_space

    problem_size = 2
    search_space = Array.new(problem_size) { |i| [-5, 5] }
    # algorithm configuration
    vel_space = Array.new(problem_size) { |i| [-1, 1] }
    max_gens = 200
    pop_size = 100
    max_vel = 100.0
    c1, c2 = 2.0, 2.0
    # execute the algorithm
    pso = PSO.new()
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)

    assert_equal(-11,best[:cost])
    assert_equal(0,best[:position][0])
  end
end