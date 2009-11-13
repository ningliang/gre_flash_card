require 'rubygems'
require 'json'
require 'rufus/tokyo'

SET_COUNT = 200

# Parse words
file = File.new(ARGV[0], "r")
words = JSON.parse(file.gets)

# Create databases
word_db = Rufus::Tokyo::Table.new("words.tct")
set_db = Rufus::Tokyo::Table.new("sets.tct")

# Words and sets - split on SET_COUNT
id = 1
set_id = 1
set_aggregator = []
words.each do |word|
  word["word"].downcase!
  word["definition"].downcase!
  word_db[id] = word  
  
  set_aggregator.push id
  if set_aggregator.length.eql? SET_COUNT or id.eql? words.length
    first = word_db[set_aggregator.first.to_s]["word"]
    last = word_db[set_aggregator.last.to_s]["word"]
    set_db[set_id] = { "title" => "#{first} to #{last}", "words" => set_aggregator.to_json, "count" => set_aggregator.size.to_s }
    set_id += 1
    set_aggregator.clear
  end
  
  id += 1
end

word_db.close
set_db.close

# words id -> { word: word, definition: definition }
# sets id -> { name: blah, words: [1, 2, 3, ...] }