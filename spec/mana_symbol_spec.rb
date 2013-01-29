require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe ManaSymbol do
  it "should parse a single colored mana correctly" do
    result = ManaSymbol.parse("B")
    result.should == [0, ManaSymbol.new("B")]
  end

  it "should parse colorless-only correctly" do
    result = ManaSymbol.parse("2")
    result.should == [2]
  end

  it "should parse multiple colored mana correctly" do
    result = ManaSymbol.parse("B/G")
    result.should == [0, ManaSymbol.new("B", "G")]
  end

  it "should parse a combo of colored and colorless correctly" do
    result = ManaSymbol.parse("4GGB/RW/U")
    result.should == [4, ManaSymbol.new("G"), ManaSymbol.new("G"), ManaSymbol.new("B", "R"), ManaSymbol.new("W", "U")]
  end

  it "should match simple mana symbols correctly" do
    ManaSymbol.new("B").matches?(ManaSymbol.new("B")).should == true
    ManaSymbol.new("U").matches?(ManaSymbol.new("B")).should == false
  end

  it "should match multicolored symbols correctly" do
    ManaSymbol.new("B").matches?(ManaSymbol.new("B", "U")).should == true
    ManaSymbol.new("W").matches?(ManaSymbol.new("B", "U")).should == false
    ManaSymbol.new("B", "U").matches?(ManaSymbol.new("B")).should == true
    ManaSymbol.new("B", "U").matches?(ManaSymbol.new("U")).should == true
    ManaSymbol.new("B", "U").matches?(ManaSymbol.new("W")).should == false
    ManaSymbol.new("B", "U").matches?(ManaSymbol.new("U", "W")).should == true
  end
end