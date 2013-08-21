require "mechanize"
require "pry"

loop do
  agent = Mechanize.new
  page = agent.get("http://localhost:3000/items")

  categories_node = page.search(".h-column")
  # binding.pry
  items_node = page.search(".h-item")
  items = items_node.map.with_index do |item, index| 
    forms = item.search("form.move").map do |form| 
      {
        :name => form.attribute("class").value.split(" ")[1],
        :form => Mechanize::Form.new(form, agent, page) 
      }
    end

    {
      :title => item.search(".p-title").text,
      :description => item.search(".p-description").text,
      :index => index,
      :forms => forms 
    }
  end

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

  items[args[0].to_i][:forms].find {|form| !!form[:name].match(/\A#{args[1]}/)}[:form].submit
end
