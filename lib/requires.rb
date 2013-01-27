for file in %w[card basic_land deck phenotype]
  require File.expand_path(File.join(File.dirname(__FILE__), file))
end
