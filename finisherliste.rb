# frozen_string_literal: true
# Gibt Teilnehmer für die Finisherliste aus.

# Erzeugt eine Excel-Tabelle mit den folgenden Spalten:
#  | Name | 18 Runden Zeit | Notiz |

# ruby finisherliste.rb

require_relative 'fetch'
require 'win32ole'

LONG_ID = false

participants = Fetch.new.participants

def show_list(list, title)
  excel = WIN32OLE.new('Excel.Application')
  excel.Visible = true
  workbook = excel.Workbooks.Add
  sheet = workbook.Worksheets(1)
  sheet.Name = title

  # Write header
  sheet.Cells(1, 1).Value = 'Name'
  sheet.Cells(1, 2).Value = '18 Runden Zeit'
  sheet.Cells(1, 3).Value = 'Notiz'

  # Make first row bold
  header_range = sheet.Range(sheet.Cells(1,1), sheet.Cells(1,3))
  header_range.Font.Bold = true

  last_row = list.count > 0 ? list.count + 1 : 1

  if list.count > 0
    list.each_with_index do |participant, idx|
      sheet.Cells(idx + 2, 1).Value = participant['FLNAME']
      sheet.Cells(idx + 2, 2).Value = participant['18_Runden_Zeit']
      note = ''
      sheet.Cells(idx + 2, 3).Value = note.strip
    end
  end

  # Add 10 empty rows
  (last_row+1..last_row+10).each do |row|
    (1..3).each do |col|
      sheet.Cells(row, col).Value = ''
    end
  end

  total_rows = last_row + 10
  total_cols = 3

  # Set font Verdana Pro, size 20 for every cell used
  range = sheet.Range(sheet.Cells(1,1), sheet.Cells(total_rows,total_cols))
  range.Font.Name = 'Verdana Pro'
  range.Font.Size = 20

  # Set gridlines for all cells (by adding borders)
  xlEdgeLeft = 7
  xlEdgeTop = 8
  xlEdgeBottom = 9
  xlEdgeRight = 10
  xlInsideVertical = 11
  xlInsideHorizontal = 12
  xlContinuous = 1
  range.Borders(xlEdgeLeft).LineStyle = xlContinuous
  range.Borders(xlEdgeTop).LineStyle = xlContinuous
  range.Borders(xlEdgeBottom).LineStyle = xlContinuous
  range.Borders(xlEdgeRight).LineStyle = xlContinuous
  range.Borders(xlInsideVertical).LineStyle = xlContinuous
  range.Borders(xlInsideHorizontal).LineStyle = xlContinuous

  # Set print area to all rows/columns used
  sheet.PageSetup.PrintArea = "$A$1:$C$#{total_rows}"

  # Set first row to print as title on every page
  sheet.PageSetup.PrintTitleRows = "$1:$1"

  msg = "Excel-Tabelle \"#{title}\" wurde erstellt."
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

show_list(active.sort_by { |participant| participant['FLNAME'].to_s.downcase }, 'Finisherliste')
