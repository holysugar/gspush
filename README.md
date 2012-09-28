# Gspush

gspush: pushing data to google spreadsheet command line interface

## Installation

Add this line to your application's Gemfile:

    gem 'gspush'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gspush

## Usage

typical usage to batch process

```sh
url=(YOUR SPREADSHEET URL)
user=(YOUR SPREADSHEET EMAIL ADDRESS)
pass=(YOUR PASSWORD) # FIXME
datetime=`date +%Y%m%d %H:00:00`
num1=123
num2=456
num3=789

echo $datetime $num1 $num2 $num3 | gspush $url -u $user -p $pass
```

then append your numbers to the spreadsheet

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
