require 'rubygems'
require 'sinatra'
require 'json'
require 'rufus/tokyo/tyrant'

OK = 200
NOT_FOUND = 404
ERROR = 500

HOST = "localhost"
WORD_TABLE_PORT = 44501
SET_TABLE_PORT = 44502

# Basic settings
set :root, File.dirname(__FILE__)
mime :json, "application/json"

# Response helper
helpers do
  def json_response(code, retval)
    content_type :json
    status code
    retval.to_json if retval
  end
end

# Open db connections, parse data
before do 
  params[:data] = JSON.parse(params[:data]) unless params[:data].nil?
end

def get_set_with_words(set_id)
  word_table = Rufus::Tokyo::TyrantTable.new(HOST, WORD_TABLE_PORT)
  set_table = Rufus::Tokyo::TyrantTable.new(HOST, SET_TABLE_PORT)
  retval = nil
  set = set_table[set_id]
  unless set.nil?
    retval = {}
    retval["title"] = set["title"]
    retval["count"] = set["count"].to_i
    retval["words"] = []
    JSON.parse(set["words"]).each do |word_id|
      retval["words"].push(word_table[word_id.to_s])
    end
  end
  word_table.close
  set_table.close
  retval
end

def get_set_summaries()
  set_table = Rufus::Tokyo::TyrantTable.new(HOST, SET_TABLE_PORT)
  sets = []
  set_table.keys.each do |key|
    set = set_table[key]
    sets.push( { "title" => set["title"], "id" => key.to_i, "count" => set["count"].to_i } ) 
  end
  set_table.close
  sets
end

# DASHBOARDS

# Index
get "/" do
  sets = get_set_summaries 
  haml :index, :locals => { :sets => sets }
end

# Study a set
get "/study/:id" do |set_id|
  set = get_set_with_words(set_id)
  haml :study, :locals => { :set => set }
end


# JSON webservices

# Get all sets - JSON
get "/sets" do 
  sets = get_set_summaries
  json_response OK, sets
end

# Get a set - JSON
get "/sets/:id" do |set_id|
  set = get_set_with_words(set_id)
  code = OK
  if set.nil?
    code = NOT_FOUND
    retval = { "error" => "Set not found" }
  else
    retval = set
  end
  json_response code, retval
end


# Get all - JSON
get "/words" do
  word_table = Rufus::Tokyo::TyrantTable.new(HOST, WORD_TABLE_PORT)
  
  all_words = word_table.query do |q|
    q.order_by "word", :asc
    q.no_pk true
  end
  
  retval = {}
  retval["words"] = []
  all_words.each do |word|
    retval["words"].push(word)
  end
  retval["title"] = "All words (#{retval["words"].length} total)"
  
  word_table.close
  
  json_response OK, retval
end




















