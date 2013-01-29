require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Deck do
  context "when determining possible actions for a hand" do
    it "should only play one basic land per turn" do
      hand = [BasicLand.new("U")] * 2
      results = []
      Deck.determine_hand_play(hand, [], [], results)

      # chop out the result where we just don't play any cards
      results.reject!{|result| result.size==0}

      results.size.should == 2
      results.each do |result|
        result.size.should == 1
      end
    end
  end
  TALRANDS_INVOCATION = Card.new("Talrand's Invocation", ManaSymbol.parse("2UU"))
  context "when determining castability" do
    it "should return not castable when there isn't enough (converted)" do
      castable, remaining_land = Deck.cast(TALRANDS_INVOCATION, [])
      castable.should == false
    end

    it "should return not castable when there isn't enough (colored)" do
      castable, remaining_land = Deck.cast(TALRANDS_INVOCATION, [BasicLand.new("B")] * 4)
      castable.should == false
    end

    it "should tap all the mana when available is exactly the cost" do
      castable, remaining_land = Deck.cast(TALRANDS_INVOCATION, [BasicLand.new("B"), BasicLand.new("U")] * 2)
      castable.should == true
      remaining_land.should == []
    end

    it "should tap the correct colored lands when there is excess available" do
      castable, remaining_land = Deck.cast(TALRANDS_INVOCATION, [BasicLand.new("B")] * 3 + [BasicLand.new("U")] * 2)
      castable.should == true
      remaining_land.should == [BasicLand.new("B")]
    end

    it "should cast zero-cost spells without tapping any lands" do
      castable, remaining_land = Deck.cast(Card.new("Mox Emerald", [0]), [BasicLand.new("B")])
      castable.should == true
      remaining_land.should == [BasicLand.new("B")]
    end

    it "should cast zero-cost spells even when there are no lands on the board" do
      castable, remaining_land = Deck.cast(Card.new("Mox Emerald", [0]), [])
      castable.should == true
      remaining_land.should == []
    end
    
  end

end