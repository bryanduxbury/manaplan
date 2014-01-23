require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe PoolLoader do
  it "should load the expected cards" do
    pool = PoolLoader.load_strings(["1\tTundra Wolves\t1W", "2\tVile Rebirth\tB"])
    pool_without_land = pool.reject(&:basic_land?)
    pool_without_land.should == [Card.new("Tundra Wolves", "1W"), Card.new("Vile Rebirth", "B"), Card.new("Vile Rebirth", "B")]
  end

  it "should add 20 basic land per color used" do
    pool = PoolLoader.load_strings(["1\tTundra Wolves\t1W", "2\tVile Rebirth\tB"])
    lands = pool.select(&:basic_land?)
    lands.should == [BasicLand.new("W")] * 20 + [BasicLand.new("B")] * 20
  end

  it "should ignore lines preceeded by a pound symbol" do
    pool = PoolLoader.load_strings(["##1\tTundra Wolves\t1W", "2\tVile Rebirth\tB"])
    pool.reject(&:basic_land?).should == [Card.new("Vile Rebirth", "B")] * 2
  end

  it "should gracefully reject malformed deck lines"
end