var saysGenerator = {
  searchOnSays_: 'http://saywut.herokuapp.com/roulette.json',
  requestSays: function() {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", this.searchOnSays_, true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        // JSON.parse does not evaluate the attacker's scripts.
        var resp = JSON.parse(xhr.responseText);
        document.getElementById("wut").innerText = "\"" + resp.wut + "\"";
        document.getElementById("who").innerText = "- " + resp.who;
      }
    }
    xhr.send();
  }
};

document.addEventListener('DOMContentLoaded', function () {
  saysGenerator.requestSays();
});;
