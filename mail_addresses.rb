# frozen_string_literal: true
# Get mail addresses for all active and waitlist participants, usable so send bcc bulk mails.

# ruby mail_addresses.rb

require_relative 'fetch'

LONG_ID = false

participants = Fetch.new.participants

def id(participant)
  if LONG_ID
    "BIB #{participant['BIB']}:  #{participant['AnzeigeName']}"
  else
    "BIB #{participant['BIB']}"
  end
end

def show_list(list, title, no_title)
  if list.count > 0
    puts "#{title}:"
    list.each { |participant| puts " #{id(participant)}" }
  else
    puts no_title
  end
  puts
end

MAX_PARTICIPANTS = 50
active = []
cancellations = []
waitlist = []
substitutes = []
newSubstitutes = []
participants.each do |participant|
  if participant['Absage'] == '1'
    cancellations << participant
  elsif participant['Warteliste'] == '0'
    active << participant
  else
    waitlist << participant
  end

  if participant['BIB'].to_i > MAX_PARTICIPANTS and participant['Absage'] == '0'
    # Everyone with a bib higher than MAX_PARTICIPANTS applied initially to the waitlist
    if participant['Warteliste'] == '0'
      substitutes << participant
    else
      next if active.count + newSubstitutes.count >= MAX_PARTICIPANTS
      newSubstitutes << participant
    end
  end
end

mail_addresses_active = active.map { |participant| participant['EMAIL'] }.join(',')
mail_addresses_waitlist = waitlist.map { |participant| participant['EMAIL'] }.join(',')

puts "Found #{active.length} active participants"
puts "Mail addresses for bcc: #{mail_addresses_active}"

puts "Found #{waitlist.length} waiting participants"
puts "Mail addresses for bcc: #{mail_addresses_waitlist}"
