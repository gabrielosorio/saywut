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
    <link type="text/css" rel="stylesheet" href="//fonts.googleapis.com/css?family=Playfair+Display:400normal,400italic,700normal,700italic,900normal,900italic|Open+Sans:400normal|Lato:400normal|Open+Sans+Condensed:300normal|Raleway:400normal|Muli:400normal|Oswald:400normal|Rokkitt:400normal|Arvo:400normal|Lora:400normal|Droid+Sans:400normal&amp;subset=all">
  %body
    = yield

@@ index
#main-wrapper
  %h1
    <span class="even">Say</span>What?
  %input{ type: 'text', name: 'say_what' }

  %h2
    Says<span class="even">Who?</span>
  %input{ type: 'text', name: 'says_who' }
