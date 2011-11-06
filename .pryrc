Pry.config.commands.import Pry::ExtendedCommands::Experimental
#Pry.config.pager = false
#Pry.config.color = false
#Pry.config.commands.command "add", "Add a list of numbers together" do |*args|
#  output.puts "Result is: #{args.map(&:to_i).inject(&:+)}"
#end
#Pry.config.history.should_save = false
#Pry.config.prompt = [proc { "input> " },
#                     proc { "     | " }]

begin
  require 'awesome_print' 
  Pry.config.print = proc { |output, value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output) }
rescue LoadError => err
  puts "no awesome_print :("
end

