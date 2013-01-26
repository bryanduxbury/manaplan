require "rubygems"
require "ruby-debug"

class Card
  attr_reader :name, :castingcost, :abilities_costs
  
  def basic_land?
    false
  end

  def converted_cost
    castingcost.sub(/\d*/, "").size + castingcost.sub(/[a-z]*/, "").to_i
  end

  def colored
    castingcost.sub(/\d*/, "").split("")
  end

  def colorless
    castingcost.sub(/[a-z]*/, "").to_i
  end
  
  def initialize(name, castingcost, abilities_costs = nil)
    @name = name
    @castingcost = castingcost
    @abilities_costs = abilities_costs
  end
end

class BasicLand < Card
  attr_reader :color

  def name
    "land(#{@color})"
  end

  def basic_land?
    true
  end

  def initialize(color)
    @color = color
  end
  
  def converted_cost
    0
  end
end

class Deck
  attr_accessor :cards

  def self.from_phenotype(mask, pool)
    # puts ">>>>>>>>>>>>> #{pool.size}"
    cards = []
    0.upto(mask.size) do |idx|
      if mask[idx]
        if pool[idx].nil?
          debugger
        end
        cards << pool[idx]
      end
    end
    Deck.new(cards)
  end
  
  def initialize(cards)
    @cards = cards
  end
  
  def util(num_shuffles, turn_limit)
    shuffle_results = []

    num_shuffles.times do |shuffle_num|
      # shuffled_cards = @cards.shuffle
      # srand(10)
      shuffled_cards = @cards.dup.sort_by{rand}
      shuffle_results << play(shuffled_cards, turn_limit)
    end
    
    spends = shuffle_results.map{|result| cumulative_mana_spent(result)}.sort
    min = spends.first
    max = spends.last
    median = spends[spends.size / 2]
    avg = spends.inject(0) {|acc, s| acc + s}.to_f / spends.size
    [min, max, median, avg]
  end

  def cumulative_mana_spent(cards_by_turn)
    total = 0
    for turn in cards_by_turn
      for card in turn
        total += card.converted_cost
      end
    end
    total
  end

  def play(deck, turn_limit)
    # get the initial hand
    hand = []
    7.times do
      hand << deck.shift
    end

    cards_played = []

    lands_played = []

    turn = 0
    cards_played_per_turn = []

    until deck.empty? || turn == turn_limit
      cards_played_this_turn = []

      # draw a card
      hand << deck.shift

      sorted_hand = hand.dup.sort_by{|card| card.converted_cost}
      # puts ">>>>>>>>>>>>>>> turn #{turn} <<<<<<<<<<<<<<<<"
      turn+=1
      # puts "Current hand: #{sorted_hand.map(&:name).join(",")}"
      # puts "Current land in play: #{lands_played.map(&:name).join(",")}"

      results = []

      determine_hand_play(sorted_hand.dup, [], lands_played, results)

      # puts "Found #{results.size} possible plays."
      sorted_hands = results.sort_by{|h| [h.inject(0){|acc, card| acc + card.converted_cost}, h.size]}
      # for h in sorted_hands
      #   puts h.map(&:name).join(",")
      #   puts "Mana spent: #{h.inject(0){|acc, card| acc + card.converted_cost}}"
      # end

      selected_hand = sorted_hands.last
      # puts "Playing #{selected_hand.map(&:name).join(",")}"

      mana_used_this_turn = 0
      for card in selected_hand
        # always put it in this turn's played cards
        cards_played_this_turn << card

        # remove card from hand
        hand.delete_at(hand.index(card))

        # put it into the proper collection
        if card.basic_land?
          lands_played << card
        else
          cards_played << card
        end
      end

      if hand.size > 7
        # puts "Hand size is #{hand.size}, so we have to discard."
        while hand.size > 7
          discarded = hand.pop
          # puts "Discarding highest-cost card #{discarded.name}"
        end
      end

      cards_played_per_turn << cards_played_this_turn

      # pause for user input
      # gets
    end

    cards_played_per_turn
  end

  def determine_hand_play(in_hand = [], so_far = [], untapped_lands = [], results = [])
    if in_hand.empty?
      results << so_far
      return
    end

    0.upto(in_hand.size - 1) do |idx|
      card = in_hand[idx]

      # treat lands and cards differently
      if card.basic_land?
        if so_far.select{|c| c.basic_land?}.empty?
          new_hand = in_hand.dup
          new_hand.delete_at(idx)
          determine_hand_play(new_hand, so_far.dup << card, untapped_lands.dup << card, results)
        end
      else
        castable, remaining_land = cast(card, untapped_lands)
        if castable
          new_hand = in_hand.dup
          new_hand.delete_at(idx)
          determine_hand_play(new_hand, so_far.dup << card, remaining_land, results)
        end
      end
    end
    results << so_far
  end
  
  def cast(card, lands)
    if card.converted_cost <= lands.size
      colorless = card.colorless
      colored = card.colored

      colored_lands = lands.dup
      uncolored_lands = []
      until colored.empty? || colored_lands.empty?
        l = colored_lands.shift
        if colored.include? l.color
          colored.delete_at(colored.index(l.color))
        else
          uncolored_lands << l
        end
      end
      uncolored_lands += colored_lands

      unless colored.empty?
        return [false, lands.dup]
      end

      until colorless == 0 || uncolored_lands.empty?
        uncolored_lands.shift
        colorless -= 1
      end
      
      unless colorless == 0
        return [false, lands.dup]
      end
      
      return [true, uncolored_lands]
    else
      [false, lands.dup]
    end
  end
end

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

population = []
120.times do |dnum|
  phenotype_mask = [true] * complete_pool.size
  # puts "seeding deck num #{dnum}"
  until phenotype_mask.select{|x| x == true}.size == 40
    # puts phenotype_mask.inspect
    # gets
    phenotype_mask[rand(phenotype_mask.size)] = false
  end
  population << phenotype_mask
end

20.times do |generation_number|
  puts "starting generation number #{generation_number}"

  to_eval = []
  for phenotype in population
    deck = Deck.from_phenotype(phenotype, complete_pool)
    util = deck.util(200, 20)
    to_eval << [phenotype, util]
    print "##"
  end

  puts

  puts "Current population performance:"
  puts to_eval.group_by{|p| p[1][3].to_i}.map{|avg_spend, phenotypes| [avg_spend, phenotypes.size]}.sort_by{|x| x[0]}.map{|x| "#{x[0]} => #{x[1]}"}.join("\n")

  new_population = []

  # sort by avg spend
  sorted_by_util = to_eval.sort_by{|pair| pair[1][3]}.map{|x| x[0]}
  top_half = sorted_by_util[sorted_by_util.size/2 .. -1]
  
  until top_half.empty?
    mom = top_half.delete_at(rand(top_half.size))
    dad = top_half.delete_at(rand(top_half.size))

    child = []
    0.upto(mom.size-1) do |gene_idx|
      if rand(2) == 1
        child << mom[gene_idx]
      else
        child << dad[gene_idx]
      end
    end
    new_population << mom << dad << child
  end

  bottom_quarter = sorted_by_util[0 ... sorted_by_util.size / 4]

  for loser in bottom_quarter
    mutant = []

    0.upto(loser.size-1) do |gene_idx|
      if rand(100) == 0
        mutant << !loser[gene_idx]
      else
        mutant << loser[gene_idx]
      end
    end

    new_population << mutant
  end

  population = new_population
end

puts "Done learning."

puts "Evaluating final population."
to_eval = []
for phenotype in population
  deck = Deck.from_phenotype(phenotype, complete_pool)
  util = deck.util(200, 20)
  to_eval << [phenotype, util]
  print '#'
end

puts

puts "Final population performance:"
grouped_by_avg_spend = to_eval.group_by{|p| p[1][3].to_i}
puts grouped_by_avg_spend.map{|avg_spend, phenotypes| [avg_spend, phenotypes.size]}.sort_by{|x| x[0]}.map{|x| "#{x[0]} => #{x[1]}"}.join("\n")

puts "Peak group achieves 20-turn mana spend of #{grouped_by_avg_spend.keys.max}."
puts "Decks: "
debugger
for phenotype in grouped_by_avg_spend[grouped_by_avg_spend.keys.max]
  cards_and_counts = Deck.from_phenotype(phenotype[0], complete_pool).cards.group_by(&:name)
  for cardname in cards_and_counts.keys.sort
    puts "  #{cards_and_counts[cardname].size}x #{cardname}"
  end
  puts
end

# deck = Deck.new(pool + lands)

# puts deck.util(1000, 20).inspect
