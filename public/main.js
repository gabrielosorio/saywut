var config = {
  perPage: 8,   // A maximum of 8 is allowed by Google
  page:    0    // The start page
}

// URL of Google's AJAX search API
var apiURL = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&callback=?';

var maxX = 0;
var maxY = 0;
var imageDisplayTime = 10000;
var waitUntilNextSearch = 10000;
var contentPadding = 50;

function calculateMaxValues(){
  maxX = $('#main-wrapper').innerWidth() - contentPadding*2;
  maxY = $('#main-wrapper').innerHeight() - contentPadding*2;
}

$(document).ready(function(){
  calculateMaxValues();
  var $content = $('#content');
  var posx = (Math.random() * (maxX - $content.width()) + contentPadding).toFixed();
  var posy = (Math.random() * (maxY - $content.height()) + contentPadding).toFixed();
  var rot = (Math.random() * 46) - 23;
  $content.css({
    'position':'absolute',
    'left':posx+'px',
    'top':posy+'px'
  });
});

$(window).load(function(){
  googleImageSearch(config);
});

$(window).resize(function(){
  calculateMaxValues();
});

//main function to search the images through google api
function googleImageSearch(parameters){
  //extend function to use the above config parameters with some other params
  parameters = $.extend({},config,parameters);
  parameters.term = parameters.term || $('#wut').text();

  // call a request to api to get the json data
  $.getJSON(apiURL,{q:parameters.term,rsz:parameters.perPage,start:parameters.page*parameters.perPage},function(r){

    //If we get at least some images
    if(r.responseData && r.responseData.results){
      var results = r.responseData.results;

      for(var i=0;i<results.length;i++){
        var posx = (Math.random() * (maxX - results[i].tbWidth) + contentPadding).toFixed();
        var posy = (Math.random() * (maxY - results[i].tbHeight) + contentPadding).toFixed();
        var rot = (Math.random() * 90) - 45;

        $newdiv = $('<img/>');
        $newdiv.attr('src',results[i].tbUrl);
        $newdiv.css({
          'width': results[i].tbWidth+'px',
          'height':results[i].tbHeight+'px',
          'position':'absolute',
          'left':posx+'px',
          'top':posy+'px',
          'display':'none',
          'transform':'rotate('+rot+'deg)',
          '-moz-transform:':'rotate('+rot+'deg)',
          '-webkit-transform:':'rotate('+rot+'deg)',
          '-o-transform:':'rotate('+rot+'deg)',
          '-ms-transform:':'rotate('+rot+'deg)'
        });
        $newdiv.appendTo('#images');
        $newdiv.delay(Math.random()*2000)
          .fadeIn(2000)
          .delay((Math.random()*imageDisplayTime)+5000)//At least 5secs
          .fadeOut(2000, function(){
           $(this).remove();
        });
      }

      //cursor is returned by google ajax search api
      var cursor = r.responseData.cursor;

      //if api returns more results then show the more result
      if(cursor.estimatedResultCount > (parameters.page+1)*parameters.perPage){
        setTimeout(function(){
          googleImageSearch({page:parameters.page+1})
        }, waitUntilNextSearch);
      }else{
        googleImageSearch({page:0})
      }
    }else{
        googleImageSearch({page:0})
    }
  });
};
