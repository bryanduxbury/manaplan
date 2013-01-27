require "rubygems"
require "rspec"
require "ruby-prof"

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "requires"))

pool = [
  Card.new("Vile Rebirth", "B"),
  Card.new("Vile Rebirth", "B"),
  Card.new("Vile Rebirth", "B"),
  Card.new("Mark of the Vampire", "3B"),
  Card.new("Bloodhunter Bat", "3B"),
  Card.new("Nefarox, Overlord of Grixis", "4BB"),
  Card.new("Talrand's Invocation", "2UU"),
  Card.new("Talrand, Sky Summoner", "2UU"),
  Card.new("Snapping Drake", "3U"),
  Card.new("Duty-Bound Dead", "B"),
  Card.new("Duty-Bound Dead", "B"),
  Card.new("Duskmantle Prowler", "3B"),
  Card.new("Sedraxis Alchemist", "2B"),
  Card.new("Undead Leotau", "5B"),
  Card.new("Zombie Goliath", "4B"),
  Card.new("Zombie Goliath", "4B"),
  Card.new("Zombie Goliath", "4B"),
  Card.new("Unsummon", "U"),
  Card.new("Mutilate", "2BB"),
  Card.new("Deathgreeter", "B"),
  Card.new("Harbor Bandit", "2B"),
  Card.new("Knight of Infamy", "1B"),
  Card.new("Bloodthrone Vampire", "1B"),
  Card.new("Wind Drake", "2U"),
  Card.new("Looming Shade", "2B"),
  Card.new("Liliana's Shade", "2BB"),
  Card.new("Mutilate", "2BB"),
  Card.new("Divination", "2U"),
  Card.new("Mind Sculpt", "1U"),
  Card.new("Mind Sculpt", "1U"),
  Card.new("Shore Snapper", "2B"),
  Card.new("Walking Corpse", "1B"),
  Card.new("Duress", "B"),
  Card.new("Telepathy", "U"),
  Card.new("Sleep", "2UU"),
  Card.new("Tricks of the Trade", "3U"),
  Card.new("Zephyr Sprite", "U")
]

lands = [BasicLand.new("B"), BasicLand.new("U")] * 10

complete_pool = pool + lands

RubyProf.start
Deck.new(complete_pool).util(200, 20)
result = RubyProf.stop
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.new("./profile.html", "w"), {})