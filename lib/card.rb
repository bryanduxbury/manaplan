class Card
  attr_reader :name, :castingcost, :abilities_costs

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
      @colored = castingcost.sub(/\d*/, "").split("")
    end
    @colored
  end

  def colorless
    if @colorless.nil?
      @colorless = castingcost.sub(/[a-z]*/, "").to_i
    end
    @colorless
  end

  def initialize(name, castingcost, abilities_costs = nil)
    @name = name
    @castingcost = castingcost
    @abilities_costs = abilities_costs
  end
end
