require 'sinatra'
require 'sinatra/content_for'
require 'date'

def setup_index_view()
    # Perhaps I'm not doing something right...
    # I don't have a single line of duplicated code
    # in those in my get and post calls, so this is 
    # difficult to refactor.
end
def valid_birthdate(this_input)
    valid = true
    delimiters = this_input.count("/") + this_input.count("-") + this_input.count(".")
    if( delimiters < 2 || this_input.match(/[A-z]/)) #this_input.match(/[A-z]/)
        valid = false
    end
    return valid
end
def only_digits(input)
    return input.scan(/\d+/).join('')
end
def get_birth_path_number(this_birthday_input)
    birthday_input = only_digits(this_birthday_input)
    birthday_array = birthday_input.split(//).map(&:to_i)
    birth_path_number = birthday_array.inject(:+).to_i
    
    while birth_path_number > 9 do
        birthday_array = birth_path_number.to_s.split(//).map(&:to_i)
        birth_path_number = birthday_array.inject(:+)
    end
    return birth_path_number
end
def birth_path_number_results(birth_path_number)
    output = "<h2>Your numerology number is #{birth_path_number}.</h3>"
    case(birth_path_number)
    when 1		
        output += "One is the leader. The number one indicates the ability to stand alone, and is a strong vibration. Ruled by the Sun."
    when 2		
        output += "This is the mediator and peace-lover. The number two indicates the desire for harmony. It is a gentle, considerate, and sensitive vibration. Ruled by the Moon."
    when 3		
        output += "Number Three is a sociable, friendly, and outgoing vibration. Kind, positive, and optimistic, Three's enjoy life and have a good sense of humor. Ruled by Jupiter."
    when 4		
        output += "This is the worker. Practical, with a love of detail, Fours are trustworthy, hard-working, and helpful. Ruled by Uranus."
    when 5		
        output += "This is the freedom lover. The number five is an intellectual vibration. These are 'idea' people with a love of variety and the ability to adapt to most situations. Ruled by Mercury."
    when 6		
        output += "This is the peace lover. The number six is a loving, stable, and harmonious vibration. Ruled by Venus."
    when 7		
        output += "This is the deep thinker. The number seven is a spiritual vibration. These people are not very attached to material things, are introspective, and generally quiet. Ruled by Neptune."
    when 8		
        output += "This is the manager. Number Eight is a strong, successful, and material vibration. Ruled by Saturn."
    when 9		
        output += "This is the teacher. Number Nine is a tolerant, somewhat impractical, and sympathetic vibration. Ruled by Mars."
    else
        output += "Never mind. You're dead."
    end
    return output
end

get '/' do
    @page_title = "Numerology App"
    @title = @page_title
    @first_name = ""
    @last_name = ""
    @subtitle = "You can tell absolutely nothing about your life based on your birthdate alone, but for kicks we're going to pretend you can..."
    erb :form
end
post '/' do
    first_name = params[:name_first]
    last_name = params[:name_last]
    birth_date = params[:birthdate].gsub("/", "-").to_s
    if valid_birthdate(birth_date)
        redirect "/message/#{first_name}/#{last_name}/#{birth_date}"
    else
        @page_title = "Numerology App - Oops!"
        @title = @page_title
        @subtitle = "You can tell absolutely nothing about your life based on your birthdate alone, but for kicks we're going to pretend you can..."
        @first_name = first_name
        @last_name = last_name
        @error = "Please enter a valid birthday (mmddyyyy)!"
        erb :form
    end
end
get '/message/:name_first/:name_last/:birth_date' do
    @first_name = params[:name_first]
    @last_name = params[:name_last]
    @birth_date = params[:birth_date].gsub("-", "/").gsub(".", "/")
    # @date = DateTime.parse(@birth_date)
    @birth_display = DateTime.strptime(@birth_date, "%m/%d/%Y").strftime("%-m/%-d/%Y")
    @page_title = "Numerology App"
    @title = "Here are your Numerology results, #{@first_name}!"
    @subtitle = "Your (#{@first_name} #{@last_name}'s) birthday was entered as #{@birth_display}"
    @message = birth_path_number_results(get_birth_path_number(@birth_date))
    erb :index
end
