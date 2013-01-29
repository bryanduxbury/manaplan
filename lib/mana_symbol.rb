class ManaSymbol
  def self.parse(str)
    tokens = str.split("")
    colorless = 0
    while tokens.first =~ /\d/
      colorless *= 10
      colorless += tokens.shift.to_i
    end

    symbols = [colorless]

    colors = []
    combined = 0
    until tokens.empty?
      colors = [tokens.shift]
      while tokens.first == "/"
        tokens.shift
        colors << tokens.shift
      end
      symbols << ManaSymbol.new(*colors)
    end

    symbols
  end

  attr_accessor :colors
  
  def initialize(*colors)
    @colors = colors
  end

  def to_s
    @colors.join("/")
  end

  def matches?(mana_symbol)
    (@colors & mana_symbol.colors).any?
  end
  
  def ==(other)
    @colors == other.colors
  end
end