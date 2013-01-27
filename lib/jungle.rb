class Jungle
  def initialize(population_size, card_pool, deck_size, number_of_generations, number_of_shuffles, number_of_turns)
    @population_size = population_size
    @card_pool = card_pool
    @deck_size = deck_size
    @number_of_generations = number_of_generations
    @number_of_shuffles = number_of_shuffles
    @number_of_turns = number_of_turns
  end

  def be_savage
    generate_population
    evolve
    summarize
  end

  private

  def generate_population
    @population = []
    @population_size.times do |dnum|
      phenotype_mask = [true] * @card_pool.size
      until phenotype_mask.select{|x| x == true}.size == @deck_size
        phenotype_mask[rand(phenotype_mask.size)] = false
      end
      @population << Phenotype.new(phenotype_mask, complete_pool)
    end
  end

  def evolve
    @number_of_generations.times do |generation_num|
      generation(generation_num)
    end
  end
  
  def generation(generation_number)
    puts "starting generation number #{generation_number}"

    for phenotype in population
      phenotype.evaluate(36, 10)
      print "#"
    end
    puts

    print_population_stats(population)

    new_population = []

    sorted_by_util = population.sort_by(&:min_spend)
    
    breed_top_half(sorted_by_util, new_population)

    mutate_second_quarter(sorted_by_util, new_population)

    @population = new_population
  end

  def breed_top_half(sorted_pop, new_population)
    top_half = sorted_pop[sorted_pop.size/2 .. -1]

    until top_half.empty?
      mom = top_half.delete_at(rand(top_half.size))
      dad = top_half.delete_at(rand(top_half.size))

      new_population << mom << dad << Phenotype.breed(mom, dad)
    end
  end

  def mutate_second_quarter(sorted_pop, new_population)
    bottom_quarter = sorted_pop[sorted_pop.size / 4 ... sorted_pop.size / 2]

    for loser in bottom_quarter
      new_population << Phenotype.mutate(loser, 100)
    end
  end

  def summarize
    puts "Evaluating final population."
    for phenotype in population
      phenotype.evaluate(36, 10)
      print '#'
    end

    puts "Final population performance:"
    print_population_stats(population)
    grouped_by_min_spend = population.group_by(&:min_spend)

    puts "Peak group achieves a minimum 20-turn mana spend of #{grouped_by_min_spend.keys.max}."
    puts "Decks: "

    for phenotype in grouped_by_min_spend[grouped_by_min_spend.keys.max]
      puts phenotype.deck.to_s
      puts
    end
  end

  def print_population_stats()
    puts "Current population performance:"
    puts @population.group_by{|phenotype| phenotype.min_spend}.map{|min_spend, phenotypes| [min_spend, phenotypes.size]}.sort_by{|x| x[0]}.map{|x| "#{x[0]} => #{x[1]}"}.join("\n")
  end
end
