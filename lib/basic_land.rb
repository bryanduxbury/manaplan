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