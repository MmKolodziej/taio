__author__ = 'Alek'

from dfa import Automata


symbols_list = 'abc'  # '01'

accepting_states = [1]  # [1, 3]

correct_words = ['aacaaa', 'c', 'bbc', 'caaaaa', 'ca', 'ac', 'bca', 'aabbc', 'abaaabbababac', 'abaabacaaaaa',
                 'abca']  # ['0', '1000', '101111', '1', '1010111001', '1010101010101', '111', '101']
incorrect_words = ['cb', 'acb', 'aa', 'a', 'b', 'ba', 'bba', 'bbaaaa', 'ababaaacaaaaab', 'aaabbabababacababaabc', 'cc',
                   'acc', 'abbabacacacab', 'ccb']  # ['00', '01', '0101110', '01010101010', '000100010','001']

states_count = 3  # 4


def transition_vector_to_matrix(transitions_vector, no_states, symbols_list):
    """turns a vector of transition values into a matrix with no_rows rows"""
    transition_lists = {}

    for i in range(len(symbols_list)):
        symbol = symbols_list[i]
        transition_lists[symbol] = []
        for j in range(no_states):
            val = int(round(transitions_vector[i * no_states + j]))
            transition_lists[symbol].append(val)

    return transition_lists


def dfa_pso_func(transitions_vector):#, symbols_list, accepting_states, correct_words, incorrect_words):
    """Input function for the PSO algorithm.
    Given a vector of transition values for an automata, it returns the number of words
    the automata computed wrong"""

    a = Automata(symbols_list)

    transition_lists = transition_vector_to_matrix(transitions_vector, states_count, symbols_list)
    a.transition_lists = transition_lists

    errors_count = 0

    for word in correct_words:
        end_state = a.compute_word(word)
        if not end_state in accepting_states:
            errors_count += 1

    for word in incorrect_words:
        end_state = a.compute_word(word)
        if end_state in accepting_states:
            errors_count += 1

    return errors_count



