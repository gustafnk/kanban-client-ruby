require "mechanize"
require "pry"

loop do
agent = Mechanize.new
page = agent.get("http://localhost:3000/items")

items_node = page.search("[itemtype$=KanbanItem]")
items = items_node.map.with_index do |item, index| 
  forms = item.search("form.move").map do |form| 
    {
      :name => form.attribute("class").value.split(" ")[1],
      :form => Mechanize::Form.new(form, agent, page) 
    }
  end

  {
    :title => item.search("[itemprop=title]").text,
    :description => item.search("[itemprop=status]").text,
    :index => index,
    :forms => forms 
  }
end

# pp items

# items[0][:forms].find {|form| form[:name] == "working"}[:form].submit

items.each do |item|
  puts "(" + item[:index].to_s + ") " + item[:title] + ", " + item[:description]
  item[:forms].each do |form|
    puts "  " + form[:name]
  end
  puts
end

puts "Enter command: "
input = gets.chomp
args = input.split(" ")
# binding.pry
items[args[0].to_i][:forms].find {|form| !!form[:name].match(/\A#{args[1]}/)}[:form].submit


#binding.pry

#pp items.first[:forms]
end
