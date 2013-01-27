class Phenotype
  def self.breed(mom, dad)
    m = mom.card_mask
    d = dad.card_mask

    possible_positions = []
    0.upto(m.size-1) do |gene_idx|
      mg = m[gene_idx]
      dg = d[gene_idx]
      if mg || dg 
        possible_positions << gene_idx
      end
    end

    until possible_positions.size == m.select{|x| x}.size
      possible_positions.delete_at(rand(possible_positions.size))
    end

    child = [false] * m.select{|x| x}.size
    for idx in possible_positions
      child[idx] = true
    end

    Phenotype.new(child, mom.card_pool)
  end

  def self.mutate(old_phenotype, chance_of_mutation)
    expressed_idx = []
    unexpressed_idx = []

    old_phenotype.card_mask.size.times do |idx|
      if old_phenotype.card_mask[idx]
        expressed_idx << idx
      else
        unexpressed_idx << idx
      end
    end

    new_mask = old_phenotype.card_mask.dup

    if rand(100) < chance_of_mutation
      new_mask[expressed_idx[rand(expressed_idx.size)]] = false
      new_mask[unexpressed_idx[rand(unexpressed_idx.size)]] = true
    end

    Phenotype.new(new_mask, old_phenotype.card_pool)
  end

  attr_reader :card_mask, :card_pool, :deck
  attr_reader :min_spend, :max_spend, :mean_spend, :avg_spend

  def initialize(card_mask, card_pool)
    @card_mask = card_mask
    @card_pool = card_pool
    @deck = Deck.from_phenotype(@card_mask, card_pool)
  end

  def evaluate(num_shuffles, turns_to_simulate)
    if @min_spend.nil?
      @min_spend, @max_spend, @mean_spend, @avg_spend = @deck.util(num_shuffles, turns_to_simulate)
    end
  end
end