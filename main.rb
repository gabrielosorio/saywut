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
  field :crap_count, type: Integer, default: 0
end

get '/' do
  haml :index
end

get '/list/?' do
  Saying.all.to_s
end

get '/roulette/?' do
  haml :roulette, locals: { saying: Saying.where(:crap_count.lt => 3).sample }
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

put '/flag-as-crap' do
  saying = Saying.find(params[:id])
  if saying.inc(:crap_count, 1)
    redirect back
  else
    "Yes and yes: This is an error, and I didn't have time to format it."
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
      #content form { width: 400px; padding: 0 4px; -webkit-box-sizing: border-box; -moz-box-sizing: border-box; -ms-box-sizing: border-box; box-sizing: border-box; }
      h1, h2 { text-align: center; text-shadow: 1px 1px rgba(255, 165, 115, 0.5); }
      h1 { font-size: 78px; }
      h2 { font-size: 62px; padding: 0 20px; -webkit-box-sizing: border-box; -moz-box-sizing: border-box; -ms-box-sizing: border-box; box-sizing: border-box; }
      h2.author { font-size: 50px; text-align: right; }
      .field { width: 100%; }
      input, input:focus { border: none; outline: none; width: 100%; background: black; color: white; padding: 20px; font-size: 28px; border-radius: 26px; box-shadow: 1px 1px rgba(255, 165, 115, 0.5); }
      input[type=submit] { position: absolute; left: -9000px; visibility: hidden; }
      #share-quote-button, #flag-as-crap-button input[type=submit] { position: fixed; height: 70px; width: 70px; border-radius: 8px; }
      #share-quote-button { left: 50px; bottom: 25px; background: url('../images/share.png') no-repeat center; background-size: 75% auto; }
      #flag-as-crap-button input[type=submit] { top: 25px; right: 50px; left: auto; visibility: visible; background: url('../images/poo-icon.png') no-repeat center; background-size: 50px auto; text-indent: -9000; box-shadow: none; text-indent: -90000px; }
      #share-quote-button:hover, #flag-as-crap-button input[type=submit]:hover { background-color: rgba(255, 255, 255, 0.1); box-shadow: inset 0 0 10px rgba(255, 255, 255, 0.5); }
      .right-tooltip { display: none; position: absolute; top: 0; left: 90px; float: left; width: 300px; padding: 14px; border-radius: 8px; background-color: rgba(255, 255, 255, 0.1); box-shadow: inset 0 0 10px rgba(255, 255, 255, 0.5); }
      .right-tooltip::before { content: ' '; position: absolute; top: 36%; left: -20px; border-color: transparent; border-right-color: rgba(255, 255, 255, 0.3); border-width: 10px; border-style: solid; }
      .right-tooltip input { font-size: 14px; font-family: sans-seriff; padding: 10px; border-radius: 8px; font-family: sans-seriff; }
      @media all and (max-width: 680px) {
        #main-wrapper { display: block; }
        #content, #content form { width: 100%; margin: 0; }
        #content { -webkit-box-sizing: border-box; -moz-box-sizing: border-box; -ms-box-sizing: border-box; box-sizing: border-box; }
        #main-wrapper.black #content { padding-top: 70px; }
        #main-wrapper.black .title-wrapper { position: fixed; top: 0; width: 100%; height: 70px; background: black; }
        #main-wrapper.black h1 { font-size: 48px; margin: 0; }
        #main-wrapper.black h2 { font-size: 40px; }
        #content h1, #content h2 { display: inline-block; width: 100%; }
        #content h1 { margin: 24px 0; font-size: 72px; }
        #content h2 { margin: 22px 0; font-size: 58px; padding: 0 10px; }
        #share-quote-button { width: 50px; height: 42px; top: 14px; left: 5px; }
        #share-quote-button::after { content: ' '; display: block; width: 100%; height: 70px; }
        .right-tooltip { width: 180px; padding: 3px; }
        .right-tooltip::before { top: 28%; }
        .right-tooltip input { padding: 8px; }
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
    .title-wrapper
      %h1 SayWut?
      #share-quote-button
        .right-tooltip
          %input{ type: 'text', value: request.base_url + '/quote/' + saying.id }
      #flag-as-crap-button
        %form{ action: '/flag-as-crap', method: 'POST' }
          %input{ type: 'hidden', name: '_method', value: 'put' }
          %input{ type: 'hidden', name: 'id', value: saying.id }
          %input{ type: 'submit', value: 'Flag as Cr*p', alt: 'Flag as Cr*p' }
    %h2
      &#8220;
      = saying.wut
      &#8221;
    %h2.author
      &#8212;
      = saying.who

:javascript
  // show the tooltip
  var shareButton = document.getElementById('share-quote-button');
  shareButton.onclick = function() {
    var tooltip = this.children[0];
    // select the tooltip text
    tooltip.className += ' show';
    tooltip.children[0].select();
  };
