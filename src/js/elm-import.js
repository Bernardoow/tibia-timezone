document.addEventListener('DOMContentLoaded', function() {
    var app = Elm.Main.fullscreen();
    app.ports.get_timezones.subscribe(function(word) {
        app.ports.timezones.send(moment.tz.names());
    });
    app.ports.save_tz_preference.subscribe(function(preference) {
        save_tz_preference(preference, function(){
            app.ports.save_tz_preference_return.send(true);
            getCurrentTabUrl((url) => {
                if (url.indexOf('secure.tibia.com/community/?subtopic=characters')!== -1){
                    get_tz_preference((data)=> {
                        convert_to_timezone(data.tibia_tz_preference);
                    });
                }
            });
        });
    });

    app.ports.get_tz_preference.subscribe(function(preference) {
        get_tz_preference(function(data){
            if(data.tibia_tz_preference){
                app.ports.timezone_preference.send(data.tibia_tz_preference);
            }
        });
    });

    function get_tz_preference(callback){
        chrome.storage.sync.get('tibia_tz_preference', callback);
    };

    function save_tz_preference(preference, callback){
        chrome.storage.sync.set({'tibia_tz_preference': preference}, callback);
    };
  });



function getCurrentTabUrl(callback) {
  var queryInfo = {
    active: true,
    currentWindow: true
  };

  chrome.tabs.query(queryInfo, (tabs) => {
    var tab = tabs[0];
    var url = tab.url;

    console.assert(typeof url == 'string', 'tab.url should be a string');

    callback(url);
  });

}