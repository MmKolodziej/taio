require 'test/unit'
require_relative '../pso/ocr_pso'
require_relative '../image_generation/csv_image_factory'

class ForthPhaseTests < Test::Unit::TestCase

  def test_ocr_pso
    #init the pso object
    images_filepath = '../jastrzebska/Native.csv'
    symbols_list = DeterministicAutomata.generate_symbols_list(12)
    states_count = 10

    pso =  OcrPso.new(symbols_list, 0, images_filepath, nil, true, true)
    puts pso.sample_images.count

    # problem configuration
    problem_size = states_count * symbols_list.count
    search_space = Array.new(problem_size) { |i| [0, states_count-1] }
    images_count = pso.images_count
    puts "we have #{pso.classes_count} different images"

    # algorithm configuration
    max_gens = 1000000
    pop_size = 10 + (2 * Math.sqrt(problem_size)).to_i
    max_vel = 1.0
    vel_space = Array.new(problem_size) { |i| [-max_vel, max_vel] }
    c1, c2 = 1.0, 1.0

    # execute the algorithm
    best = pso.search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    puts "done! Solution: f=#{best[:cost]}, s=#{best[:position].inspect}"

    #we can compute at most half of the words incorrectly
    assert_in_delta(0,best[:cost],images_count/2)
  end
end