chrome.runtime.onMessage.addListener(function(request, sender) {
  if (request.action == "getSource") {
    message.innerText = request.source;

    //alert ( newArray )

    //testing - send info to Python Flask localhost
    //get ip addresses from current page
    $.ajax({
        type: 'POST',
        url: 'http://127.0.0.1:5000/download',
        data: 'BLATEST__BLA',
        dataType: 'json'
    })
    .fail(function(){
        sendMessage( "info", "The web server isn't running!" );
        sendMessage( "enableDownloadButton" );
    });

  }
});

function onWindowLoad() {

  //var message = document.querySelector('#message');

  chrome.tabs.executeScript(null, {
    file: "getPagesSource.js"
  }, function() {
    // If you try and inject into an extensions page or the webstore/NTP you'll get an error
    if (chrome.runtime.lastError) {
      message.innerText = 'There was an error injecting script : \n' + chrome.runtime.lastError.message;
    }
  });

}

window.onload = onWindowLoad;