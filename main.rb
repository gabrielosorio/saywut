require 'rubygems'
require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

__END__

@@ layout
%html
  %head
    <link href='http://fonts.googleapis.com/css?family=Playfair+Display:400,900' rel='stylesheet' type='text/css'>
    :css
      * { font-family: 'Playfair Display', serif; font-weight: bold; }
      body { display: -webkit-box; -webkit-box-pack: center; -webkit-box-orient: horizontal; -webkit-box-align: center; } display: -moz-box; -moz-box-pack: center; -moz-box-orient: horizontal; -moz-box-align: center; display: box; box-pack: center; box-orient: horizontal; box-align: center; }
      #main-wrapper { width: 800px; -webkit-box-flex: 1; }
      h1, h2 { text-align: center; text-shadow: 1px 1px rgba(255, 165, 115, 0.5); }
      h1 { font-size: 78px; }
      h2 { font-size: 62px; }
      .field { width: 400px; margin: auto; }
      input, input:focus { border: none; outline: none; width: 100%; background: black; color: white; padding: 20px; font-size: 28px; border-radius: 26px; box-shadow: 1px 1px rgba(255, 165, 115, 0.5); }
      input[type=submit] { visibility: hidden; }

  %body
    = yield

@@ index
#main-wrapper
  %form{ action: '/spread_the_word', method: 'POST' }
    %h1
      <span class="even">Say</span>Wat?
    .field
      %input{ type: 'text', name: 'say_what' }

    %h2
      Sez<span class="even">Who?</span>
    .field
      %input{ type: 'text', name: 'says_who' }
    
    %input{ type: "submit", value: "Spread the Word" }
