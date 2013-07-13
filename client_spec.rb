

require "net/http"
require "microformats2"
require "microdata"
require "pp"
require "pry"
require "nokogiri"
require 'open-uri'

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

describe "nokogiri parsing" do

  before(:each) do
    @doc = Nokogiri::HTML(open("http://localhost:3000/items")) 
    # binding.pry
  end

  it "parses the title " do
    @doc.at_css("h1").text.should eq("My kanban board")
  end

  it "parses a kanban item" do
    item = @doc.at_css("[itemprop=item]")
    item.css("[itemprop=title]").text.should eq("It works here too")
  end
  
  it "has a link to the create form for a new item" do 
    # binding.pry
    link = @doc.css("[itemtype$=KanbanBoard] a[rel=create]").first['href']
    link.should eq("/items/new")
  end
end
