var LastFM;

LastFM = (function() {
  function LastFM() {}

  LastFM.API_KEY = "14b5d40e28da8a1c3b1a66fe312b98dd";

  LastFM.API_ADDRESS = "http://ws.audioscrobbler.com/2.0/";

  LastFM.radioByArtist = function(artist, callback) {
    var request;
    request = this._requestURL('radio.search', {
      name: artist
    });
    return this._get(request, function(data) {
      console.log(data);
      return callback(data.events.event);
    });
  };

  LastFM.eventsByLatLng = function(params, callback) {
    var request;
    request = this._requestURL('geo.getevents', params);
    return this._get(request, function(data) {
      return callback(data.events.event);
    });
  };

  LastFM._get = function(url, callback) {
    var req;
    req = new XMLHttpRequest();
    req.onload = function() {
      return callback(JSON.parse(req.responseText));
    };
    req.open("GET", url, true);
    return req.send();
  };

  LastFM._requestURL = function(method, params) {
    var key, url, val;
    url = "" + this.API_ADDRESS + "?method=" + method + "&format=json";
    for (key in params) {
      val = params[key];
      url += "&" + key + "=" + val;
    }
    return url += "&api_key=" + this.API_KEY;
  };

  return LastFM;

})();

//# sourceMappingURL=lastfm.js.map
