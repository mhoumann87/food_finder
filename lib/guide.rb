require 'resturant'
require 'support/string_extend'

class Guide

  class Config
    @@actions = ['list', 'find', 'add', 'quit']
    def self.actions; @@actions; end
  end
  
  def initialize(path=nil)
    # locate the resturant text file at path
    Resturant.filepath = path
    if Resturant.file_usable?
      puts "Found resturant file."
    # or create a new file
    elsif Resturant.create_file
      puts "Created resturant file."
    # exit if create fails
    else 
      puts "Exiting. \n\n"
      exit!
    end
  end

  def launch!
    introduction

    # action loop

    result = nil
    until result == :quit
      action, args = get_action
      result = do_action(action, args)
    end
    conslusion
  end

  def introduction
    puts "\n\n<<<<<Welcome to food finder>>>>>\n\n"
    puts "This is an  interactive guide to help you find the food you crave.\n\n"
  end

  def conslusion
    puts "\n<<<Goodbye and Bon Appetit!>>>\n\n\n"
  end

  def get_action
    action = nil
    # Keep asking for user input until we get a valid action
    until Guide::Config.actions.include?(action)
      puts "Actions: " + Guide::Config.actions.join(", ") unless action
      print "> "
      user_response = gets.chomp
      args = user_response.downcase.strip.split (" ")
      action = args.shift
    end
    return action, args
  end

  def do_action(action, args=[])
    case action
    when 'list'
      list
    when 'find'
      keyword = args.shift
      find(keyword)
    when 'add'
      add
    when 'quit'
      return :quit
    else
      puts "\nI don't understand what you mean.\n"
    end
  end

  def list(args=[])
    sort_order = args.shift
    sort_order = args.shift if sort_order == 'by'
    sort_order = "name" unless ['name', 'cuisine', 'price'].include?(sort_order)

    output_action_header("Listing resturants")
    resturants = Resturant.saved_resturants
    resturants.sort! do |r1, r2|
      case sort_order
      when 'name'
        r1.name.downcase <=> r2.name.downcase
      when 'cuisine'
        r1.cuisine.downcase <=> r2.cuisine.downcase
      when 'price'
        r1.price.to_i <=> r2.price.to_i
      end
    end
    output_resturant_table(resturants)
    puts "Sort by 'list name', 'list cuisine', 'list price'\n\n"
  end

  def add
    output_action_header("Add a Resturant")
    resturant = Resturant.build_using_questions
    if resturant.save
      puts "\nResturant Added\n\n"
    else
      puts "\nSave Error! Resturant not added\n\n"
    end
  end

  def find(keyword="")
    output_action_header("Find a resturant")
    if keyword
      # search
      resturants = Resturant.saved_resturants
      found = resturants.select do |rest|
        rest.name.downcase.include?(keyword.downcase) ||
        rest.cuisine.downcase.include?(keyword.downcase) ||
        rest.price.to_i <= keyword.to_i
      end
      output_resturant_table(found)
    else
      puts "Find using a key phrase to search the resturant list."
      puts "Ex: 'find pizza', 'find Italian', 'find ita' "
    end
  end

  private

  def output_action_header(text)
    puts "\n#{text.upcase.center(60)}\n\n"
  end

  def output_resturant_table(resturants=[])
    print " " + "Name".ljust(30)
    print " " + "Cuisine".ljust(20)
    print " " + "Price".rjust(6) + "\n"
    puts "-" * 60
    resturants.each do |rest|
      line = " " << rest.name.titleize.ljust(30)
      line << " " + rest.cuisine.titleize.ljust(20)
      line << " " + rest.formatted_price.rjust(6)
      puts line
    end
    puts "No listings found" if resturants.empty?
    puts "-" * 60
    puts "\n\n"
    
  end

end

