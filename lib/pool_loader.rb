class PoolLoader
  def self.load(path)
    load_strings(File.read(path).split("\n"))
  end

  def self.load_strings(list_of_strings)
    card_pool = []
    list_of_strings.each do |line|
      tokens = line.split("\t")

      copies = tokens.shift.to_i
      card = Card.new(tokens.shift, tokens.shift, tokens)
      copies.times do
        card_pool << card
      end
    end

    card_pool.map{|card| card.colored}.flatten.uniq.each do |color_used|
      20.times do
        card_pool << BasicLand.new(color_used)
      end
    end

    card_pool
  end
end