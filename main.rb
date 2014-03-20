require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongoid'
require 'nokogiri'
require 'json'

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

before do
   headers 'Access-Control-Allow-Origin' => 'http://www.neonroots.com',
            'Access-Control-Allow-Methods' => ['GET']
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

get '/api/roulette/?' do
  content_type :json
  { saying: Saying.all.sample }.to_json
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
    %title SayWut | Straightforward Hadron-colliding Super-slinky Quote Generator
    %meta{ content: 'True', name: 'HandheldFriendly' }
    %meta{ content: '320', name: 'MobileOptimized' }
    %meta{ content: 'width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0', name: 'viewport' }
    <link href='http://fonts.googleapis.com/css?family=Playfair+Display:400,900' rel='stylesheet' type='text/css'>
    :css
      .show { display: block !important; }
      body { margin: 0; padding: 0; }
      * { font-family: 'Playfair Display', serif; font-weight: bold; }
      #main-wrapper { height: 100%; width: 100%; display: -webkit-flexbox; display: -webkit-box; display: -moz-box; display: -ms-flexbox; display: -webkit-flex; display: flex; -webkit-justify-content: center; -moz-justify-content: center; -ms-justify-content: center; justify-content: center; -webkit-flex-align: center; -ms-flex-align: center; -webkit-align-items: center; align-items: center; }
      #main-wrapper.black, #main-wrapper.black #content { background: black; color: white; }
      #content form { width: 400px; }
      h1, h2 { text-align: center; text-shadow: 1px 1px rgba(255, 165, 115, 0.5); }
      h1 { margin: 0 0 052px; font-size: 78px; }
      h2 { font-size: 62px; }
      h2.author { font-size: 50px; text-align: right; }
      .field { width: 100%; }
      input, input:focus { border: none; outline: none; width: 100%; background: black; color: white; padding: 20px; font-size: 28px; border-radius: 26px; box-shadow: 1px 1px rgba(255, 165, 115, 0.5); }
      input[type=submit] { position: absolute; left: -9000px; visibility: hidden; }
      #share-quote-button { position: fixed; left: 50px; bottom: 25px; height: 70px; width: 70px; background: url('../images/share.png') no-repeat center center; background-size: 75% auto; border-radius: 8px; }
      #share-quote-button:hover { background-color: rgba(255, 255, 255, 0.1); box-shadow: inset 0 0 10px rgba(255, 255, 255, 0.5); }
      .right-tooltip { display: none; position: absolute; top: 0; left: 90px; float: left; width: 300px; padding: 14px; border-radius: 8px; background-color: rgba(255, 255, 255, 0.1); box-shadow: inset 0 0 10px rgba(255, 255, 255, 0.5); }
      .right-tooltip::before { content: ' '; position: absolute; top: 36%; left: -20px; border-color: transparent; border-right-color: rgba(255, 255, 255, 0.3); border-width: 10px; border-style: solid; }
      .right-tooltip input { font-size: 14px; font-family: sans-seriff; padding: 10px; border-radius: 8px; font-family: sans-seriff; }
      @media all and (max-width: 570px) {
        #main-wrapper { display: block; overflow: hidden; }
        #content, #content form { width: 100%; margin: 0; }
        #content { padding: 0 10px; -webkit-box-sizing: -moz-border-box; -ms-box-sizing: border-box; box-sizing: border-box; }
        #main-wrapper.black #content { max-height: calc(100% - 70px); overflow: auto; }
        #main-wrapper.black #content::after { content: ' '; display: block; position: absolute; bottom: 70px; left: 0; width: 100%; height: 30px; background: linear-gradient(transparent, black); }
        #content h1, #content h2 { margin: 22px 0; display: inline-block; width: 100%; }
        #content h1 { font-size: 72px; }
        #content h2 { font-size: 40px; }
        #share-quote-button { height: 58px; bottom: 5px; left: 15px; }
        .right-tooltip { width: 180px; padding: 8px; }
      }

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
