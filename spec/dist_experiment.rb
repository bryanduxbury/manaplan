require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "requires"))

pool = PoolLoader.load("examples/draft_1.tsv")
deck = Deck.new(pool)

[1, 10, 15, 20, 36, 72, 150, 300, 1000, 10000].each do |shuffles|
  srand(1)
  puts deck.util(shuffles, 10).inspect
end