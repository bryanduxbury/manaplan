require "rubygems"
require "trollop"
require "ruby-debug"

for file in %w[card basic_land deck phenotype jungle pool_loader]
  require File.expand_path(File.join(File.dirname(__FILE__), file))
end
