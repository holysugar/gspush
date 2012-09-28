require 'optparse'
require 'google_drive'

require_relative './gspush/version'

class Gspush
  class WorksheetNotFound < StandardError; end

  attr_reader :url, :delimiter, :lines

  def initialize(url, options = {})
    @url = url

    @delimiter = options[:delimiter]
    @nullpush  = options[:nullpush]
    @username  = options[:username]
    @password  = options[:password]

    @prepend_timestamp = options[:prepend_timestamp]
    @sheet_title = options[:sheet_title]

    @lines = []
  end

  def push(line)
    @lines.push line
  end

  def parse_lines
    now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @lines.each_with_object([]) {|line, obj|
      values = separate(line)
      if @prepend_timestamp
        values.unshift(now)
      end
      unless values.empty?
        obj << values
      end
    }
  end

  def save
    spreadsheet = open(@url, @username, @password)

    sheet = select_worksheet(spreadsheet)
    raise WorksheetNotFound if sheet.nil?
    update(sheet, parse_lines)
  end

  def separate(line)
    line.split(@delimiter)
  end

  private

  def open(url, username, password)
    session     = GoogleDrive.login(username, password)
    spreadsheet = session.spreadsheet_by_url(url)
  end

  def select_worksheet(spreadsheet)
    if @sheet_title
      spreadsheet.worksheet_by_title(@sheet_title)
    else
      spreadsheet.worksheets.first
    end
  end

  def update(sheet, lines)
    sheet.update_cells(sheet.num_rows+1, 1, lines)
    sheet.save
  end

  class CLI
    def self.execute(argv)
      argv, options = parse_option(argv)

      gspush = Gspush.new(argv[0], options)
      while line = $stdin.gets # FIXME
        gspush.push(line)
      end
      gspush.save
    end

    def self.parse_option(argv_original)
      options = {}

      opt = OptionParser.new
      opt.on('-d delim', 'input delimiter') {|v| options[:delimiter] = v }
      opt.on('-u username', 'Google Drive username(email)') {|v| options[:username] = v }
      opt.on('-p password', 'user password') {|v| options[:password] = v } # XXX how should i get this?
      opt.on('-s sheet_title', 'worksheet title (default: first worksheet)') {|v| options[:sheet_title] = v }
      opt.on('-t', 'prepend timestamp cell') {|v| options[:prepend_timestamp] = v }

      opt.banner = "Usage: gspush URL [options]"
      opt.version = Gspush::VERSION

      argv = opt.parse(argv_original)

      if argv.empty?
        puts opt.banner
        exit 1
      end

      [argv, options]
    end
  end
end
