require "mechanize"
require "pry"

def parse_item (item_node, index)

  forms = item_node.search(".p-forms form").map do |form| 
    {
      :name => form.attribute("data-rel").value.split(" ")[1],
      :form => Mechanize::Form.new(form, @agent, @page),
      :is_next => !!(form.get_attribute("data-rel").match "next")
    }
  end

  {
    :title => item_node.search(".p-name").text,
    :description => item_node.search(".p-description").text,
    :index => index,
    :forms => forms 
  }
end

loop do
  system("clear") 

  @agent = Mechanize.new
  @page = @agent.get("http://localhost:3001/items")

  categories_node = @page.search(".h-column")
  categories = categories_node.map do |category_node|

    item_nodes = category_node.search(".h-item")

    items = item_nodes.map.with_index do |item, index|
      parse_item(item, index)
    end

    { 
      :name => category_node.search("> .p-name").text,
      :items => items
    }

  end

  categories.each do |category|
    # TODO Extract display_category
    puts "------------------------"
    puts category[:name]
    puts "------------------------"

    # TODO Extract display_items
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

  puts
  puts "Enter command: (from index [to])"

  # TODO Extract get_form_from_input
  input = gets.chomp

  args = input.split(" ")

  found_category = categories.select do |category| 
    category[:name].match /^#{args[0]}/i 
  end

  form = found_category[0][:items][args[1].to_i][:forms].find do |form| 
    if !!args[2]
      !!form[:name].match(/\A#{args[2]}/)
    else
      form[:is_next]
    end
  end

  # TODO End extract get_form_from_input

  form[:form].submit
end
