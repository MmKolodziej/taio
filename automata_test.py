__author__ = 'Alek'

import unittest

from dfa import Automata


class MyTestCase(unittest.TestCase):
    def test_automata_is_word_from_alphabet_method(self):
        symbols_list = ['a', 'b', 'c']
        a = Automata(symbols_list)
        self.assertEqual(a.is_word_from_alphabet('aaccabba'), True)
        self.assertEqual(a.is_word_from_alphabet('aacbdd'), False)
        single_symbol_word = 'a'
        self.assertEqual(a.is_word_from_alphabet(single_symbol_word), True)
        single_symbol_word = 'x'
        self.assertEqual(a.is_word_from_alphabet(single_symbol_word), False)

    def test_automata_compute_word_method_validation(self):
        symbols_list = ['a', 'b', 'c', '1', '5', '0']
        a = Automata(symbols_list)

        correct_word = 'aacc1ba0a'
        incorrect_word = 'aasdc'

        self.assertEqual(a.compute_word(incorrect_word), False)
        self.assertNotEqual(a.compute_word(correct_word), -1)
        incorrect_word = 'abc3'
        self.assertEqual(a.compute_word(incorrect_word), False)
        correct_word = '01005001'
        self.assertNotEquals(a.compute_word(correct_word), -1)

    """
    Automata.compute_word method tests
    """

    def test_binary_words_with_non_important_zeroes(self):
        """Binary word with non-important zeroes
            Should return  {Not_accepted} for '01001','00001'
            and {accepted} for '0', '101011'"""
        binary_symbols_list = '01'
        a = Automata(binary_symbols_list, 4)

        transition_lists = {
            '0': [1, 2, 2, 3],
            '1': [3, 2, 2, 3]
        }
        a.transition_lists = transition_lists
        accepting_states = [1, 3]

        incorrect_binary_words = ['01001', '00001', '010100010']
        correct_binary_words = ['0', '101011', '1010100010']

        for word in incorrect_binary_words:
            end_state = a.compute_word(word)
            self.assertNotIn(end_state, accepting_states)

        for word in correct_binary_words:
            end_state = a.compute_word(word)
            self.assertIn(end_state, accepting_states)

    def test_simple_regex_words(self):
        """First, a "b{0,1}a*b" regex language"""
        symbols = 'ab'
        a = Automata(symbols, 3)

        transition_lists = {
            'a': [1, 1, -1],
            'b': [1, 2, -1]
        }

        a.transition_lists = transition_lists
        accepting_states = [2]

        correct_words = ['baaaaaaab', 'ab', 'baab']
        incorrect_words = ['baaa', 'aaaa', 'b', 'a']

        for word in incorrect_words:
            end_state = a.compute_word(word)
            self.assertNotIn(end_state, accepting_states)

        for word in correct_words:
            end_state = a.compute_word(word)
            self.assertIn(end_state, accepting_states)


if __name__ == '__main__':
    unittest.main()
