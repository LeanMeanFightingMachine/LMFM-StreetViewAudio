define(function(require) {
  var App, Sound, StreetViewWrapper, deezer, elements, lastFM, onGoogleMapsReady, sources, start;
  onGoogleMapsReady = require("util/onGoogleMapsReady");
  lastFM = require("api/lastfm");
  deezer = require("api/deezer");
  StreetViewWrapper = require("wrapper/StreetViewWrapper");
  Sound = require("audio/Sound");
  start = {
    lat: 51.514708,
    long: -0.130377
  };
  elements = {
    streetView: document.querySelectorAll('.streetView')[0]
  };
  sources = [];

  /*
  		get lastfm radio streams for each artists events
  		add params to new Sound constructor
  			lat long
  			radio stream url
  		when street view updates update each source with streetview position/heading etc
   */
  return App = (function() {
    function App() {
      console.log("Hello World :)");
      this.streetView = new StreetViewWrapper();
      onGoogleMapsReady((function(_this) {
        return function() {
          _this.streetView.initialise(elements.streetView);
          _this.streetView.setLatLong(start.lat, start.long);
          return _this._loadData(_this._dataLoaded);
        };
      })(this));
    }

    App.prototype._dataLoaded = function() {
      return console.log('data loaded', sources);
    };

    App.prototype._loadData = function(complete) {
      return LastFM.eventsByLatLng(start.lat, start.long, (function(_this) {
        return function(eventData) {
          var artist, event, indexaa, sourceData, _i, _len, _results;
          _results = [];
          for (indexaa = _i = 0, _len = eventData.length; _i < _len; indexaa = ++_i) {
            event = eventData[indexaa];
            console.log(indexaa);
            sourceData = {};
            sourceData.location = event.venue.location["geo:point"];
            sourceData.artist = artist = event.artists.headliner;
            _results.push(Deezer.searchArtist(encodeURI(artist), function(artistData) {
              if (artistData) {
                return Deezer._get(artistData.artist.tracklist, function(trackData) {
                  var cue, _j, _len1, _ref;
                  sourceData.cues = [];
                  _ref = trackData.data;
                  for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                    cue = _ref[_j];
                    sourceData.cues.push(cue.preview);
                  }
                  console.log(indexaa);
                  if (indexaa === eventData.length) {
                    return complete();
                  }
                });
              }
            }));
          }
          return _results;
        };
      })(this));
    };

    return App;

  })();
});

//# sourceMappingURL=app.js.map
