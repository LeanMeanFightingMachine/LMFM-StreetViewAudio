var Deezer;

Deezer = (function() {
  function Deezer() {}

  Deezer.API_KEY = "14b5d40e28da8a1c3b1a66fe312b98dd";

  Deezer.API_ADDRESS = "https://api.deezer.com";

  Deezer.searchArtist = function(artist, callback) {
    var request;
    request = this._requestURL('search', {
      q: artist
    });
    return this._get(request, function(data) {
      var artistObj, _i, _len, _ref;
      _ref = data.data;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        artistObj = _ref[_i];
        if (artistObj.artist.name === artist) {
          callback(artistObj);
          return;
        } else {
          callback(false);
        }
      }
    });
  };

  Deezer._get = function(url, callback) {
    var req;
    req = new XMLHttpRequest();
    req.onload = function() {
      return callback(JSON.parse(req.responseText));
    };
    req.open("GET", url, true);
    return req.send();
  };

  Deezer._requestURL = function(method, params) {
    var key, url, val;
    url = "" + this.API_ADDRESS + "/" + method + "?";
    for (key in params) {
      val = params[key];
      url += "" + key + "=" + val;
    }
    return url;
  };

  return Deezer;

})();

//# sourceMappingURL=deezer.js.map
