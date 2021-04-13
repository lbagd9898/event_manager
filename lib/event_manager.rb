require 'csv'
require "google/apis/civicinfo_v2"
require "erb"



def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end



def clean_phonenumber(phonenumber)
    phonenumber = phonenumber.to_s.gsub(/[()-. ]/, "")
    if phonenumber.nil?
        return "Invalid Phone Number"
    elsif phonenumber.length == 11
        if phonenumber[0] = "1"
            return phonenumber[1..10]
        end 
    elsif phonenumber.length >= 11 or phonenumber.length < 10 
        return "Invalid Phone Number"
    else 
        return phonenumber
    end




def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
          ).officials

    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end


    
    

def save_thank_you_letter(id,form_letter)
    Dir.mkdir('output') unless Dir.exists?('output')
  
    filename = "output/thanks_#{id}.html"
  
    File.open(filename, 'w') do |file|
      file.puts form_letter
    end
  end
end 



CONTENTS = CSV.open(
    'event_attendees.csv', 

    headers: true,

    header_converters: :symbol
)

def find_peak_day 
    weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    days = []
    days_counter = Hash.new(0)
    CONTENTS.each do |row|
        datetime = row[:regdate]
        parsed_date = Time.strptime(datetime, '%M/%d/%y %k:%M')
        weekday = parsed_date.wday
        days.push(weekday)
    end 
    days.each{ |day| days_counter[day] += 1 }
    max = days_counter.max_by{ |k, v| v }
    all_maxes = days_counter.select{ |k, v| v == max[1] }
    most_popular_weekdays = []
    all_maxes.keys.each do |key|
        most_popular_weekdays.push(weekdays[key])
    end 
    most_popular_weekdays
        


end

def find_peak_times
    reg_hours = []
    hours_counter = Hash.new(0)
    CONTENTS.each do |row|
        datetime = row[:regdate]
        parsed_date = Time.strptime(datetime, '%M/%d/%y %k:%M')
        hour = parsed_date.strftime('%k')
        reg_hours.push(hour)
    end
    reg_hours.each{ |hour| hours_counter[hour] += 1}
    max = hours_counter.max_by{|k,v| v}
    all_maxes = hours_counter.select{ |k, v| v == max[1] }
    all_maxes.keys.each do |key|
        p "#{key}:00"
    end
end 



template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
    id = row[0]
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id,form_letter)

end 


