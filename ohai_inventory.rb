computer_name = `scutil --get ComputerName`.strip

hash = `ohai`

hash.hash.each do |key|
  puts key
end
