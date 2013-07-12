

require "net/http"
require "microformats2"
require "pp"
require "pry"

describe "#foo" do
  it "fails" do
    response = Net::HTTP.get('localhost', '/items', 3000) 
    collection = Microformats2.parse(response)
    # binding.pry

    item = collection.first

    item.title.to_s.should eq("It works here too")
    item.status.to_s.should eq("backlog")
  end
end
