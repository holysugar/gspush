require 'optparse'
require 'google_drive'


class Gspush

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
      opt.on('-d delim')    {|v| options[:delimiter] = v }
      opt.on('-n')          {|v| options[:nullpush] = v }
      opt.on('-u username') {|v| options[:username] = v }
      opt.on('-p password') {|v| options[:password] = v } # XXX how should i get this?
      opt.on('-s sheet_title') {|v| options[:sheet_title] = v }
      opt.on('-t') {|v| options[:prepend_timestamp] = v }

      argv = opt.parse(argv_original)

      [argv, options]
    end
  end
end
