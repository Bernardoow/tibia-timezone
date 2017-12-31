$(function() {
    chrome.storage.sync.get('tibia_tz_preference', (data) =>{
        if(data.tibia_tz_preference){
            convert_to_timezone(data.tibia_tz_preference);
        }
    });

});


function convert_to_timezone(timezone){
    var trs = $("tr:contains('Character Deaths')").siblings();
    for (var i = 0; i < trs.length; i++) {
        var tibia_tz = moment($(trs[i]).find("td:first").text().replace(" CET", "+01:00").replace(" CEST", "+02:00"), "MMM D YYYY, HH:mm:ssZ").tz("Europe/Berlin"); //#.format();
        var new_tz = tibia_tz.clone().tz(timezone).format("MMM DD YYYY, HH:mm:ss");
        $(trs[i]).find("td:first").text(new_tz);
    }
};
