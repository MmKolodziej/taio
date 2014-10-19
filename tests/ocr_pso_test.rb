require 'test/unit'
require_relative '../ocr_pso'
class MyTest < Test::Unit::TestCase

  def test_ocr_pso
    #init the pso object
    symbols_list = ['0', '1']
    states_count = 4

    pso =  OCR_PSO.new(symbols_list, states_count)

    # problem configuration
    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0, states_count-1] } #TODO: check if this are inclusive or exclusive boundaries

    # algorithm configuration
    vel_space = Array.new(problem_size) { |i| [-1, 1] }
    max_gens = 100
    pop_size = 300
    max_vel = 100.0
    c1, c2 = 3.0, 2.0

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    puts "done! Solution: f=#{best[:cost]}, s=#{best[:position].inspect}"

    #we can compute at most one word incorrectly
    assert_in_delta(0,best[:cost],1)
  end
end