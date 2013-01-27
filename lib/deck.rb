class Deck
  attr_accessor :cards

  def self.from_phenotype(mask, pool)
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
      turn+=1

      results = []

      determine_hand_play(sorted_hand.dup, [], lands_played, results)

      sorted_hands = results.sort_by{|h| [h.inject(0){|acc, card| acc + card.converted_cost}, h.size]}

      selected_hand = sorted_hands.last

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
        while hand.size > 7
          discarded = hand.pop
        end
      end

      cards_played_per_turn << cards_played_this_turn
    end

    cards_played_per_turn
  end

  def self.determine_hand_play(in_hand = [], so_far = [], untapped_lands = [], results = [])
    0.upto(in_hand.size - 1) do |idx|
      card = in_hand[idx]

      # treat lands and cards differently
      if card.basic_land?
        if so_far.select{|c| c.basic_land?}.empty?
          # new_hand = in_hand.dup
          # new_hand.delete_at(idx)
          # if we're playing a land, then omit any other basic lands from further investigation
          new_hand = in_hand[idx+1 ... in_hand.size].reject(&:basic_land?)
          determine_hand_play(new_hand, so_far + [card], untapped_lands + [card], results)
        end
      else
        castable, remaining_land = cast(card, untapped_lands)
        if castable
          # new_hand = in_hand.dup
          # new_hand.delete_at(idx)
          new_hand = in_hand[idx+1 ... in_hand.size]
          determine_hand_play(new_hand, so_far + [card], remaining_land, results)
        end
      end
    end
    results << so_far
  end

  def self.cast(card, lands)
    if card.converted_cost <= lands.size
      colorless = card.colorless
      colored = card.colored.dup

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
        return [false, lands]
      end

      # if we've got enough colorless, then chop off the necessary lands and return true
      if uncolored_lands.size >= colorless
        return [true, uncolored_lands[colorless .. -1]]
      end

      [false, lands]
    else
      [false, lands]
    end
  end

  def to_s
    s = ""
    cards_by_name = cards.group_by(&:name)
    for cardname in cards_by_name.keys.sort
      s << "  #{cards_by_name[cardname].size}x #{cardname}\n"
    end
    s
  end
end
