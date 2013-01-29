class Card
  attr_reader :name, :castingcost, :abilities_costs

  def initialize(name, castingcost, abilities_costs = nil)
    @name = name
    @castingcost = castingcost
    @abilities_costs = abilities_costs
  end

  def basic_land?
    false
  end

  def converted_cost
    if @converted_cost.nil?
      @converted_cost = colored.size + colorless
    end
    @converted_cost
  end

  def colored
    if @colored.nil?
      @colored = castingcost[1..-1]
    end
    @colored
  end

  def colorless
    if @colorless.nil?
      @colorless = castingcost.first
    end
    @colorless
  end

  def ==(other)
    @name == other.name
  end
end
