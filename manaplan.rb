require "rubygems"
require "ruby-debug"

require "lib/card"
require "lib/basic_land"
require "lib/deck"
require "lib/phenotype"

pool = [
  Card.new("Vile Rebirth", "B"),
  Card.new("Vile Rebirth", "B"),
  Card.new("Vile Rebirth", "B"),
  Card.new("Mark of the Vampire", "3B"),
  Card.new("Bloodhunter Bat", "3B"),
  Card.new("Nefarox, Overlord of Grixis", "4BB"),
  Card.new("Talrand's Invocation", "2UU"),
  Card.new("Talrand, Sky Summoner", "2UU"),
  Card.new("Snapping Drake", "3U"),
  Card.new("Duty-Bound Dead", "B"),
  Card.new("Duty-Bound Dead", "B"),
  Card.new("Duskmantle Prowler", "3B"),
  Card.new("Sedraxis Alchemist", "2B"),
  Card.new("Undead Leotau", "5B"),
  Card.new("Zombie Goliath", "4B"),
  Card.new("Zombie Goliath", "4B"),
  Card.new("Zombie Goliath", "4B"),
  Card.new("Unsummon", "U"),
  Card.new("Mutilate", "2BB"),
  Card.new("Deathgreeter", "B"),
  Card.new("Harbor Bandit", "2B"),
  Card.new("Knight of Infamy", "1B"),
  Card.new("Bloodthrone Vampire", "1B"),
  Card.new("Wind Drake", "2U"),
  Card.new("Looming Shade", "2B"),
  Card.new("Liliana's Shade", "2BB"),
  Card.new("Mutilate", "2BB"),
  Card.new("Divination", "2U"),
  Card.new("Mind Sculpt", "1U"),
  Card.new("Mind Sculpt", "1U"),
  Card.new("Shore Snapper", "2B"),
  Card.new("Walking Corpse", "1B"),
  Card.new("Duress", "B"),
  Card.new("Telepathy", "U"),
  Card.new("Sleep", "2UU"),
  Card.new("Tricks of the Trade", "3U"),
  Card.new("Zephyr Sprite", "U")
]

lands = [BasicLand.new("B"), BasicLand.new("U")] * 10

complete_pool = pool + lands

def print_population_stats(pop)
  puts "Current population performance:"
  puts pop.group_by{|phenotype| phenotype.min_spend}.map{|min_spend, phenotypes| [min_spend, phenotypes.size]}.sort_by{|x| x[0]}.map{|x| "#{x[0]} => #{x[1]}"}.join("\n")
end

population = []
120.times do |dnum|
  phenotype_mask = [true] * complete_pool.size
  until phenotype_mask.select{|x| x == true}.size == 40
    phenotype_mask[rand(phenotype_mask.size)] = false
  end
  population << Phenotype.new(phenotype_mask, complete_pool)
end

20.times do |generation_number|
  puts "starting generation number #{generation_number}"

  for phenotype in population
    phenotype.evaluate(200, 20)
    print "#"
  end

  puts

  print_population_stats(population)
  
  new_population = []

  # sort by min spend
  sorted_by_util = population.sort_by(&:min_spend)
  top_half = sorted_by_util[sorted_by_util.size/2 .. -1]
  
  until top_half.empty?
    mom = top_half.delete_at(rand(top_half.size))
    dad = top_half.delete_at(rand(top_half.size))

    new_population << mom << dad << Phenotype.breed(mom, dad)
  end

  bottom_quarter = sorted_by_util[0 ... sorted_by_util.size / 4]

  for loser in bottom_quarter
    new_population << Phenotype.mutate(loser, 10)
  end

  population = new_population
end

puts "Done learning."

puts "Evaluating final population."
for phenotype in population
  phenotype.evaluate(200, 20)
  print '#'
end

puts

puts "Final population performance:"
print_population_stats(population)
grouped_by_min_spend = population.group_by(&:min_spend)

puts "Peak group achieves a minimum 20-turn mana spend of #{grouped_by_min_spend.keys.max}."
puts "Decks: "

for phenotype in grouped_by_min_spend[grouped_by_min_spend.keys.max]
  puts phenotype.deck.to_s
  puts
end
