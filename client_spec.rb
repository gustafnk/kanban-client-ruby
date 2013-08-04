
require "net/http"
require "pp"
require "pry"
require 'open-uri'
require 'mechanize'

describe "mechanize" do
  it "gets the page" do
    agent = Mechanize.new
    page = agent.get("http://localhost:3000/items")
    link = page.links.find {|link| link.rel.first == "create"}
    create_page = link.click
    form = create_page.form
    form.field_with(:name => "item[title]").value = "Title from test"
    form.field_with(:name => "item[description]").value = "Description from test"
    # form.submit

    # binding.pry
  end
end


