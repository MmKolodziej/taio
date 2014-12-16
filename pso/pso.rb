class PSO
  def initialize(verbose=true)
    self.verbose = verbose
  end

  attr_accessor :verbose

  def objective_function(vector)
    (vector[0]-2)**2 -11
  end

  def random_vector(minmax)
    # We will need some gaussian random shit here I suppose
    Array.new(minmax.size) do |i|
      minmax[i][0] + (minmax[i][1] - minmax[i][0]) * rand
    end
  end

  def create_particle(search_space, vel_space)
    particle = {}
    particle[:position]   = random_vector(search_space)
    particle[:cost]       = objective_function(particle[:position])
    particle[:b_position] = Array.new(particle[:position])
    particle[:b_cost]     = particle[:cost]
    particle[:velocity]   = random_vector(vel_space)
    particle
  end

  def get_global_best(population, current_best=nil)
    gbest_has_changed = false
    population.sort! { |x, y| x[:cost] <=> y[:cost] }
    best = population.first
    if current_best.nil? || best[:cost] < current_best[:cost]
      current_best = {}
      current_best[:position] = Array.new(best[:position])
      current_best[:cost]     = best[:cost]
      gbest_has_changed = true
    end
    return current_best, gbest_has_changed
  end

  def update_velocity(particle, gbest, max_v, c1, c2)
    particle[:velocity].each_with_index do |v, i|
      v1 = c1 * rand * (particle[:b_position][i] - particle[:position][i])
      v2 = c2 * rand * (gbest[:position][i] - particle[:position][i])
      particle[:velocity][i] = v + v1 + v2
      particle[:velocity][i] = max_v if particle[:velocity][i] > max_v
      particle[:velocity][i] = -max_v if particle[:velocity][i] < -max_v
    end
  end

  def update_position(part, bounds)
    part[:position].each_with_index do |v, i|
      part[:position][i] = v + part[:velocity][i]
      if part[:position][i] > bounds[i][1]
        part[:position][i] = bounds[i][1] #-(part[:position][i]-bounds[i][1]).abs THIS A BUG
        part[:velocity][i] *= -1.0
      elsif part[:position][i] < bounds[i][0]
        part[:position][i] = bounds[i][0] #+(part[:position][i]-bounds[i][0]).abs
        part[:velocity][i] *= -1.0
      end
    end
  end

  def update_best_position(particle)
    # returns true if best position is updated
    return if particle[:cost] > particle[:b_cost]
    particle[:b_cost] = particle[:cost]
    particle[:b_position] = Array.new(particle[:position])
  end

  def search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
    puts "computing..."
    pop = Array.new(pop_size) { create_particle(search_space, vel_space) }
    gbest, gbest_has_changed = get_global_best(pop)
    iterations_wo_change = 0
    max_gens.times do |gen|
      pop.each do |particle|
        update_velocity(particle, gbest, max_vel, c1, c2)
        update_position(particle, search_space)
        particle[:cost] = objective_function(particle[:position])
        update_best_position(particle)
      end
      gbest, gbest_has_changed = get_global_best(pop, gbest)
      iterations_wo_change = gbest_has_changed ? 0 : iterations_wo_change + 1
      print_progress(gen+1, gbest[:cost], iterations_wo_change) if verbose
    end
    puts
    gbest
  end

  def print_progress(gen, fitness, iterations_wo_change)
    puts "> gen #{gen+1}, errors count: #{fitness}, iterations without change: #{iterations_wo_change}"
  end
end
