require "lib/requires"

opts = Trollop::options do
  opt :pop, "Number of unique decks to start with", :type => :int
  opt :size, "Number of cards in a deck", :type => :int
  opt :generations, "Number of generations in the genetic algorithm portion", :type => :int
  opt :turns, "Number of turns to play when simulating deck performance", :type => :int
  opt :shuffles, "Number of shuffles to simulate when evaluating deck performance", :type => :int
  opt :pool, "Path to a YAML file containing the definition of the card pool", :type => :string
  opt :seed, "Seed for the random number generator. Specify this to get consistent behavior between runs.", :type => :int
end

card_pool = PoolLoader.load(opts[:pool])

Jungle.new(opts[:pop], card_pool, opts[:size], opts[:generations], opts[:shuffles], opts[:turns]).be_savage