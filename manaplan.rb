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
  def initialize(cards)
    @cards = cards
  end
  
  def util(num_shuffles)
    num_shuffles.times do |shuffle_num|
      # shuffled_cards = @cards.shuffle
      srand(10)
      shuffled_cards = @cards.dup.sort_by{rand}
      
      # get the initial hand
      hand = []
      7.times do
        hand << shuffled_cards.shift
      end
      
      cards_played = []
      
      lands_played = []
      
      until shuffled_cards.empty?
        # draw a card
        hand << shuffled_cards.shift
        
        sorted_hand = hand.sort_by{|card| card.converted_cost}
        puts "Current hand: #{sorted_hand.map(&:name).join(",")}"

        results = []
        debugger
        determine_hand_play(sorted_hand, [], lands_played, results)

        puts "Found #{results.size} possible plays."
        sorted_hands = results.sort_by{|hand| hand.inject(0){|acc, card| acc + card.converted_cost}}
        for h in sorted_hands
          puts h.map(&:name).join(",")
          puts "Mana spent: #{hand.inject(0){|acc, card| acc += card.converted_cost}}"
        end
        raise
      end
    end
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

      unless colored.empty?
        return [false, lands]
      end

      until colorless == 0 || uncolored_lands.empty?
        colored_lands.shift
        colorless -= 1
      end
      
      unless colorless == 0
        return [false, lands]
      end
      
      return [true, uncolored_lands]
    else
      [false, lands]
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

lands = [BasicLand.new("B"), BasicLand.new("U")] * 7

deck = Deck.new(pool + lands)

deck.util(20)
