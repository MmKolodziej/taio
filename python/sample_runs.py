__author__ = 'Alek'
from dfa import Automata

transition_lists = {
    '0': [3,1,2,2],
    '1': [1,1,2,2]
}

a=Automata('01')
a.transition_lists = transition_lists
correct_words = ['0', '1000', '101111', '1', '1010111001', '1010101010101', '111']
incorrect_words = ['00', '01', '0101110', '01010101010', '000100010', '0000101010000101']

accepting_states = [1,3]
errors_count = 0

for word in correct_words:
    end_state = a.compute_word(word)
    if not end_state in accepting_states:
        errors_count += 1

for word in incorrect_words:
    end_state = a.compute_word(word)
    if end_state in accepting_states:
        errors_count += 1

print errors_count