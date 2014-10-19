require 'test/unit'

require_relative '../automata.rb'

class AutomataTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_is_word_from_alphabet
    symbols_list = %w(a b c)
    target = Automata.new(symbols_list, 2, nil)

    assert_equal(true, target.word_is_from_alphabet?('aaccabba'))
    assert_equal(false, target.word_is_from_alphabet?('aacbdd'))
  end

  def test_is_word_from_alphabet_single_symbol_word
    symbols_list = %w(a b c)
    target = Automata.new(symbols_list, 2, nil)

    assert_equal(true, target.word_is_from_alphabet?('a'))
    assert_equal(false, target.word_is_from_alphabet?('x'))
  end

  def test_automata_compute_word_method_validation
    symbols_list = %w(a b c 1 5 0)
    a = Automata.new(symbols_list, 2, nil)

    correct_word = 'aacc1ba0a'
    incorrect_word = 'aasdc'

    assert_equal(nil, a.compute_word(incorrect_word))
    assert_not_equal(-1, a.compute_word(correct_word))

    incorrect_word = 'abc3'
    assert_equal(nil, a.compute_word(incorrect_word))
    correct_word = '01005001'
    assert_not_equal(-1, a.compute_word(correct_word))
  end

  def test_binary_words_with_non_important_zeroes
  # Binary word with non-important zeroes
  #       Should return  {Not_accepted} for '01001','00001'
  #       and {accepted} for '0', '101011'
  binary_symbols_list = %w(0 1)
  transition_matrix = [[1, 2, 2, 3],
                       [3, 2, 2, 3]]
  a = Automata.new(binary_symbols_list, 4, transition_matrix)

  accepting_states = [1, 3]

  incorrect_binary_words = %w(01001 00001 010100010)
  correct_binary_words = %w(0 101011 1010100010)

  incorrect_binary_words.each do |word|
    end_state = a.compute_word(word)
    assert_equal(false, accepting_states.include?(end_state))
    end

    correct_binary_words.each do |word|
      end_state = a.compute_word(word)
      assert_equal(true, accepting_states.include?(end_state))
    end
  end

  def test_simple_regex_words
    # First, a "b{0,1}a*b" regex language
    symbols = %w(a b)
    transition_matrix = [[1, 1, -1],[1, 2, -1]]

    a = Automata.new(symbols, 3, transition_matrix)
    accepting_states = [2]
    correct_words = %w(baaaaaaab ab baab)
    incorrect_words = %w(baaa aaaa b a)

    incorrect_words.each do |word|
      end_state = a.compute_word(word)
      assert_equal(false, accepting_states.include?(end_state))
    end

    correct_words.each do |word|
      end_state = a.compute_word(word)
      assert_equal(true, accepting_states.include?(end_state))
    end
  end
end