require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Phenotype do
  it "should maintain the same number of expressed genes when breeding" do
    cards = [Card.new("Tundra Wolves", "1W")] * 4
    a = Phenotype.new([true, true, false, false], cards)
    b = Phenotype.new([false, false, true, true], cards)
    150.times do
      Phenotype.breed(a, b).card_mask.select{|g| g == true}.size.should == 2
    end
  end
  
  it "should maintain the same number of expressed genes when mutating" do
    cards = [Card.new("Tundra Wolves", "1W")] * 4
    a = Phenotype.new([true, true, false, false], cards)
    150.times do
      new_mask = Phenotype.mutate(a, 50).card_mask
      new_mask.select{|x| x}.size.should == 2
    end
  end
end