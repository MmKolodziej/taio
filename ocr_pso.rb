require_relative'dfa_pso.rb'
require_relative'sample_image.rb'

class OCR_PSO < Rounded_PSO
  def initialize(symbols_list, states_count, images_filepath)
    @dfa = Automata.new(symbols_list, states_count, nil)
    #init images from filepath
    @sample_images = [SampleImage.new(images_filepath,1)] #TODO: change!!!, so we have a list of them
    @sample_images.each { |image| image.map_factors(symbols_list) }
  end

  def objective_function(vector)
    #let the dfa compute each of the images, and assign (dfa's end state) them to a class.
    #returns the number of images assigned to wrong class

    @dfa.set_transition_matrix_from_vector(vector)
    errors_count = 0

    @sample_images.each do |image|
      end_state = @dfa.compute_word(image.symbols_vector)
      if end_state != image.image_class
        errors_count += 1
      end
    end

    errors_count
  end
end




