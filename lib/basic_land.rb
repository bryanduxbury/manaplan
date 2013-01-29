class BasicLand < Card
  attr_reader :color

  def initialize(color)
    super("land(#{color})", "0")
    @color = ManaSymbol.new(color)
  end

  def basic_land?
    true
  end

  def converted_cost
    0
  end
end