__author__ = 'Alek'


class Automata:
    def __init__(self, symbols_list, states_count=1):
        """
        :param symbols_list: list of symbols that the automata can process (eg.: '0,1' , 'a,b,c' etc)
        :return:
        """
        self.symbols_list = symbols_list
        self.current_state = 0
        self.states_count = states_count
        self.transition_lists = self.init_transition_lists(symbols_list, states_count)

    def init_transition_lists(self, symbols_list, states_count=False):
        """
        :param symbols_list: list of symbols that the automata can process
        :param states_count: when not specified uses the automatas states count
        :return: Matrix n x m, where n = symbols count, m = states count, initialized with zeros.
        """
        if not states_count:
            states_count = self.states_count

        transition_lists = {}
        for symbol in symbols_list:
            transition_lists[symbol] = []
            for i in range(states_count):
                transition_lists[symbol].append(0)
        return transition_lists

    def is_word_from_alphabet(self, word):
        """
        Validation method for input words' format
        :param word: a string of symbols(list)
        :return: true if the automata's symbol list contains each of the word's symbols
        """
        for s in word:
            if not s in self.symbols_list:
                print("This automata's alphabet does not contain {0}".format(s))
                return False
        return True

    def compute_symbol(self, symbol):
        """
        Computes a single symbol -> changes the automata's current state to the appropriate one.
        :param symbol: the symbol to be computed (eg.: '0', 'a', 'X')
        """
        next_state = self.transition_lists[symbol][self.current_state]
        self.current_state = next_state

    def compute_word(self, word):
        """
        :param word: a list of symbols for the automata to compute (eg.: 'aabccaaa')
        :return: End state if computations successfull, False if word does not belong to automata alphabet
        """
        if not self.is_word_from_alphabet(word):
            print("The given word is not valid!")
            return False

        #print("Computing word {0},start state is {1}".format(word, self.current_state))
        for symbol in word:
            self.compute_symbol(symbol)
            #print "Computing symbol {0} The next state is {1}".format(symbol, self.current_state)

        end_state = self.current_state
        #reset the current_state for future computations
        self.current_state = 0

        return end_state


