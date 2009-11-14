require 'rubygems'
require 'json'
require 'rufus/tokyo'

# For splitting up buckets by alphabetical order
SET_COUNT = 200

# For splitting up buckets by length
BUCKET_SIZE = 3
BUCKET_COUNT = 5

ALPHABETICAL = "alpha"
LENGTH = "length"

# Parse words
file = File.new(ARGV[0], "r")
words = JSON.parse(file.gets)

# Create databases
word_db = Rufus::Tokyo::Table.new("words.tct")
set_db = Rufus::Tokyo::Table.new("sets.tct")

# Word id
word_id = 1

# Save words
words.each do |word|
  word["word"].downcase!
  word["definition"].downcase!
  word_db[word_id] = word
  word["id"] = word_id
  word_id += 1
end

# Set id
set_id = 1

# Sets - alphabetical order, by set size
set_aggregator = []
words.each do |word|
  set_aggregator.push word["id"]
  if set_aggregator.length.eql? SET_COUNT or word["id"].eql? words.length
    first = word_db[set_aggregator.first.to_s]["word"]
    last = word_db[set_aggregator.last.to_s]["word"]
    set_db[set_id] = { "title" => "#{first} to #{last}", "words" => set_aggregator.to_json, "count" => set_aggregator.size.to_s, "type" => ALPHABETICAL }
    set_id += 1
    set_aggregator.clear
  end
end

# Sets - bucket by length
buckets = []
BUCKET_COUNT.times do |i|
  buckets.push([])
end

words.each do |word|
  length = word["word"].length
  bucket_index = [(length / BUCKET_SIZE).ceil - 1, BUCKET_COUNT - 1].min
  buckets[bucket_index].push word["id"]
end

buckets.each_index do |index|
  bucket = buckets[index]
  if bucket.size > 0
    low = (index * BUCKET_SIZE) + 1
    high = (index < BUCKET_COUNT - 1) ? ((index + 1) * BUCKET_SIZE) : nil
    title = high.nil? ? "#{low}+ characters" : "#{low} to #{high} characters"
    set_db[set_id] = { "title" => title, "words" => bucket.to_json, "count" => bucket.size.to_s, "type" => LENGTH }
    set_id += 1
  end
end


# Cleanup
word_db.close
set_db.close