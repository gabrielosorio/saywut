require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongoid'
require 'nokogiri'

ENV['RACK_ENV'] ||= 'development'

configure do
  Mongoid.configure do |config|
    if ENV['RACK_ENV'] && ENV['RACK_ENV'] == 'production'
      config.sessions = { default: { uri: ENV['MONGOHQ_URL'] } }
    else
      config.sessions = { default: { uri: 'mongodb://localhost:27017/saywut' } }
    end
  end
end

class Saying
  include Mongoid::Document
  field :wut
  field :who
  field :wen, type: Time, default: Time.now
end

get '/' do
  haml :index
end

get '/list/?' do
  Saying.all.to_s
end

get '/roulette/?' do
  haml :roulette, locals: { saying: Saying.all.sample }
end

get '/quote/:id/?' do
  haml :roulette, locals: { saying: Saying.find(params[:id]) }
end

post '/spread-the-word' do
  return "Don't be leaving empty params..." if params["wut"].empty? || params["who"].empty?

  html_tags = Nokogiri::HTML::DocumentFragment.parse(params["wut"] + params["who"]).search('*')
  return "You wouldn't be trying to submit some code into this pure loving baby, would you...." if html_tags.any?

  if Saying.create(wut: params["wut"], who: params["who"])
    redirect back
  else
    "Does this unformatted text make you feel miserable enough to understand that this is an error?"
  end
end

__END__

@@ layout
%html
  %head
    <link href='http://fonts.googleapis.com/css?family=Playfair+Display:400,900' rel='stylesheet' type='text/css'>
    :css
      .show { display: block !important; }
      body { overflow: hidden }
      * { font-family: 'Playfair Display', serif; font-weight: bold; }
      #main-wrapper { height: 100%; width: 100%; display: -webkit-box; -webkit-box-pack: center; -webkit-box-orient: horizontal; -webkit-box-align: center; display: -moz-box; -moz-box-pack: center; -moz-box-orient: horizontal; -moz-box-align: center; display: box; box-pack: center; box-orient: horizontal; box-align: center; }
      #main-wrapper.black { background: black; color: white; }
      #content { padding: 0 150px; -webkit-box-flex: 1; -moz-box-flex: 1; box-flex: 1; }
      h1, h2 { text-align: center; text-shadow: 1px 1px rgba(255, 165, 115, 0.5); }
      h1 { font-size: 78px; }
      h2 { font-size: 62px; }
      h2.author { font-size: 50px; text-align: right; }
      .field { width: 400px; margin: auto; }
      input, input:focus { border: none; outline: none; width: 100%; background: black; color: white; padding: 20px; font-size: 28px; border-radius: 26px; box-shadow: 1px 1px rgba(255, 165, 115, 0.5); }
      input[type=submit] { visibility: hidden; }
      #share-quote-button { position: fixed; left: 50px; bottom: 25px; height: 70px; width: 70px; background: url('../images/share.png') no-repeat center center; background-size: 75% auto; border-radius: 8px; }
      #share-quote-button:hover { background-color: rgba(255, 255, 255, 0.1); box-shadow: inset 0 0 10px rgba(255, 255, 255, 0.5); }
      .right-tooltip { display: none; position: absolute; top: 0; left: 90px; float: left; width: 300px; padding: 14px; border-radius: 8px; background-color: rgba(255, 255, 255, 0.1); box-shadow: inset 0 0 10px rgba(255, 255, 255, 0.5); }
      .right-tooltip::before { content: ' '; position: absolute; top: 36%; left: -20px; border-color: transparent; border-right-color: rgba(255, 255, 255, 0.3); border-width: 10px; border-style: solid; }
      .right-tooltip input { font-size: 14px; font-family: sans-seriff; padding: 10px; border-radius: 8px; font-family: sans-seriff; }

  %body
    = yield

@@ index
#main-wrapper
  #content
    %form{ action: '/spread-the-word', method: 'POST' }
      %h1 SayWut?
      .field
        %input{ type: 'text', name: 'wut', autofocus: 'true' }

      %h2 SezWho?
      .field
        %input{ type: 'text', name: 'who' }

      %input{ type: "submit", value: "Spread the Word" }

@@ roulette
#main-wrapper.black
  #content
    %h1 SayWut?

    %h2
      &#8220;
      = saying.wut
      &#8221;
    %h2.author
      &#8212;
      = saying.who
    #share-quote-button
      .right-tooltip
        %input{ type: 'text', value: request.base_url + '/quote/' + saying.id }

:javascript
  // show the tooltip
  var shareButton = document.getElementById('share-quote-button');
  shareButton.onclick = function() {
    var tooltip = this.children[0];
    // select the tooltip text
    tooltip.className += ' show';
    tooltip.children[0].select();
  };
