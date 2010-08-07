# Setup
ROOT = File.join(File.dirname(__FILE__), "..")
TTS = `which ttserver`.chomp
WORD_TABLE_PORT = 44501
WORD_TABLE = "#{ROOT}/data/words.tct"
SET_TABLE_PORT = 44502
SET_TABLE = "#{ROOT}/data/sets.tct"

# Start each server
puts "Starting word db"
`nohup #{TTS} -port #{WORD_TABLE_PORT} #{WORD_TABLE} &`

puts "Starting set db"
`nohup #{TTS} -port #{SET_TABLE_PORT} #{SET_TABLE}} &`

puts "Done"
