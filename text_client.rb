require "mechanize"
require "pry"

##### I/O functions

def display_category(category)
  puts "------------------------"
  puts category[:name]
  puts "------------------------"

  category[:items].each do |item|
    # TODO Use string interpolation
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

def get_form_from_input(categories)
  input = gets.chomp

  if (input.empty?)
    return nil
  end

  args = input.split(" ")

  found_category = categories.select do |category| 
    category[:name].match /^#{args[0]}/i 
  end

  form = found_category.first()[:items][args[1].to_i][:forms].find do |form| 
    if !!args[2]
      !!form[:name].match(/\A#{args[2]}/)
    else
      form[:is_next]
    end
  end

  form
end

def display_prompt
  puts
  puts "Enter command: (from index [to])"
end


##### Extracting functions

def extract_category(category_node)

  item_nodes = category_node.search(".h-item")

  items = item_nodes.map.with_index do |item, index|
    extract_item(item, index)
  end

  { 
    :name => category_node.search("> .p-name").text,
    :items => items
  }
end

def extract_item (item_node, index)

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


##### Main loop

loop do
  system("clear") 

  @agent = Mechanize.new
  @page = @agent.get("http://localhost:3001/items")

  category_nodes = @page.search(".h-board .h-column")
  categories = category_nodes.map do |category_node|
    extract_category(category_node)
  end

  categories.each do |category|
    display_category(category)
  end

  display_prompt()

  form = get_form_from_input(categories)

  if (!form)
    next
  end

  form[:form].submit
end
