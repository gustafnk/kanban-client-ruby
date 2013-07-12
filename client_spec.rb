

require "net/http"
require "microformats2"
require "microdata"
require "pp"
require "pry"

describe "microformat parsing" do
  it "parses a kanban item" do
    response = Net::HTTP.get('localhost', '/items', 3000) 
    collection = Microformats2.parse(response)
    # binding.pry

    item = collection.first

    item.title.to_s.should eq("It works here too")
    item.status.to_s.should eq("backlog")
  end
end

describe "microdata parsing" do
  it "parses a kanban item" do

    items = Microdata.get_items('http://localhost:3000/items')
   
    # binding.pry
    item = items.first.properties["column"].first.properties["item"].first

    item.properties["title"].first.should eq("It works here too")
    item.properties["status"].first.should eq("backlog")
  end
end
