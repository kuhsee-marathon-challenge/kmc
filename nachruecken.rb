# frozen_string_literal: true
# Gibt Teilnehmer aus, die aus der Warteliste nachrücken können.

# ruby nachruecken.rb

require_relative 'fetch'

LONG_ID = true

participants = Fetch.new.participants

def id(participant)
  if LONG_ID
    "BIB #{participant['BIB']}: #{participant['FLNAME']}"
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
earlyBird = []
participants.each do |participant|
  if participant['Absage'] == '1'
    cancellations << participant
  elsif participant['Warteliste'] == '0'
    active << participant
  else
    waitlist << participant
  end
end

participants.each do |participant|
  if participant['BIB'].to_i > MAX_PARTICIPANTS and participant['Absage'] == '0'
    # Everyone with a bib higher than MAX_PARTICIPANTS applied initially to the waitlist
    if participant['Warteliste'] == '0'
      substitutes << participant
    else
      next if active.count + newSubstitutes.count >= MAX_PARTICIPANTS
      newSubstitutes << participant
    end
  end

  if participant['Frühstarter'] == '1'
    earlyBird << participant
  end
end

show_list(active, 'Aktiv', 'Keine Anmeldungen')
show_list(cancellations, 'Absagen', 'Keine Absagen')
show_list(substitutes, 'Nachgerückt', 'Keine Nachrücker')
show_list(waitlist, 'Warteliste', 'Keine Warteliste')
show_list(newSubstitutes, 'Mögliche Nachrücker', 'Keine Nachrücker möglich')
show_list(earlyBird, 'Frühstarter', 'Keine Frühstarter')

puts "Gesamt Anmeldungen:     #{participants.count}"
puts "   aktive Teilnehmer:   #{active.count}"
puts "   absagen:             #{cancellations.count}"
puts "   Nachrücker:          #{substitutes.count}"
puts "   auf Warteliste:      #{waitlist.count}"
puts "   mögliche Nachrücker: #{newSubstitutes.count}"
puts "   Frühstarter:         #{earlyBird.count}"
