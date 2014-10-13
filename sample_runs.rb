require_relative('Automata.rb')

transition_matrix = [
    [3, 1, 2, 2],
    [1, 1, 2, 2]
]

a=Automata.new(['0','1'],3, transition_matrix)

correct_words = ['0', '1000', '101111', '1', '1010111001', '1010101010101', '111']
incorrect_words = ['00', '01', '0101110', '01010101010', '000100010', '0000101010000101']

accepting_states = [1, 3]
errors_count = 0

correct_words.each {|word| errors_count+=1 if not accepting_states.include? a.compute_word(word) }
incorrect_words.each {|word| errors_count+=1 if  accepting_states.include? a.compute_word(word) }

puts errors_count
