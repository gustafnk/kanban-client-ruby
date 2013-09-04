require "mechanize"
require "pry"

def parse_item (item_node, index)

  forms = item_node.search("form.move").map do |form| 
    {
      :name => form.attribute("class").value.split(" ")[1],
      :form => Mechanize::Form.new(form, @agent, @page),
      :is_next => !!(form.get_attribute("class").match "next")
    }
  end

  {
    :title => item_node.search(".p-title").text,
    :description => item_node.search(".p-description").text,
    :index => index,
    :forms => forms 
  }
end

loop do
  system("clear") 

  @agent = Mechanize.new
  @page = @agent.get("http://localhost:3000/items")

  categories_node = @page.search(".h-column")
  categories = categories_node.map do |category_node|

    item_nodes = category_node.search(".h-item")
    items = item_nodes.map.with_index do |item, index|
      parse_item(item, index)
    end

    { 
      :name => category_node.search(".p-name").text,
      :items => items
    }

  end

  items_node = @page.search(".h-item")
  items = items_node.map.with_index do |item, index| 
    parse_item(item, index)
  end

  categories.each do |category|
    puts "------------------------"
    puts category[:name]
    puts "------------------------"
    category[:items].each do |item|
      puts "(" + item[:index].to_s + ") " + item[:title] + ", " + item[:description]
      item[:forms].each do |form|
        if (form[:is_next])
          puts " >" + form[:name]
        else
          puts "  " + form[:name]
        end
      end
      puts
    end
  end

  puts "Enter command: (from index [to])"
  input = gets.chomp
  if input.empty?
   next 
  end

  args = input.split(" ")

  found_category = categories.select do |category| 
    category[:name].match /#{args[0]}/i 
  end

  form = found_category[0][:items][args[1].to_i][:forms].find do |form| 
    if !!args[2]
      !!form[:name].match(/\A#{args[2]}/)
    else
      form[:is_next]
    end
  end

  form[:form].submit
end
