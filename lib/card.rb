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
