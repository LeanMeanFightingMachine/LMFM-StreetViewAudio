define(function(require) {
  var App, Deezer, Sound, StreetViewWrapper, async, elements, fixAngle, lastFM, onGoogleMapsReady, sources, start;
  onGoogleMapsReady = require("util/onGoogleMapsReady");
  async = require("../vendor/async");
  lastFM = require("api/lastfm");
  Deezer = require("api/deezer");
  StreetViewWrapper = require("wrapper/StreetViewWrapper");
  Sound = require("audio/Sound");
  start = {
    lat: 50.82104,
    long: -0.1356339
  };
  elements = {
    streetView: document.querySelectorAll('.streetView')[0]
  };
  sources = [];
  fixAngle = function(angle) {
    if (angle > 180) {
      return angle - 360;
    } else if (angle < -180) {
      return angle + 360;
    } else {
      return angle;
    }
  };

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
          _this.streetView.onUpdate = _this._update;
          return _this._loadEvents();
        };
      })(this));
    }

    App.prototype._update = function(position, heading) {
      var distance, headingToSource, normalizedHeading, source, _i, _len, _ref, _ref1, _results;
      _results = [];
      for (_i = 0, _len = sources.length; _i < _len; _i++) {
        source = sources[_i];
        headingToSource = google.maps.geometry.spherical.computeHeading(position, source.location);
        normalizedHeading = fixAngle(heading - headingToSource);
        distance = google.maps.geometry.spherical.computeDistanceBetween(position, source.location);
        if ((_ref = source.Sound) != null) {
          _ref.setDistanceAndHeading(distance, normalizedHeading);
        }
        _results.push((_ref1 = source.Sound) != null ? _ref1.start() : void 0);
      }
      return _results;
    };

    App.prototype._dataLoaded = function(data) {
      var source, _i, _len;
      sources = data;
      for (_i = 0, _len = sources.length; _i < _len; _i++) {
        source = sources[_i];
        source.Sound = new Sound(source.audio);
        console.log(source.venue.name);
      }
      return this.streetView.enabled = true;
    };

    App.prototype._loadEvents = function() {
      return async.waterfall([
        function(callback) {
          var events;
          events = [];
          return LastFM.eventsByLatLng({
            lat: start.lat,
            long: start.long,
            distance: 1,
            limit: 5
          }, function(eventData) {
            var event, sourceData, _i, _len;
            for (_i = 0, _len = eventData.length; _i < _len; _i++) {
              event = eventData[_i];
              sourceData = {};
              sourceData.venue = event.venue;
              sourceData.location = new google.maps.LatLng(event.venue.location["geo:point"]["geo:lat"], event.venue.location["geo:point"]["geo:long"]);
              sourceData.artist = event.artists.headliner;
              events.push(sourceData);
            }
            return callback(null, events);
          });
        }, function(events, callback) {
          var event, eventsWithData, index, _i, _len, _results;
          eventsWithData = [];
          _results = [];
          for (index = _i = 0, _len = events.length; _i < _len; index = ++_i) {
            event = events[index];
            _results.push((function(i, event) {
              return Deezer.searchArtist(event.artist, function(artistData) {
                if (artistData) {
                  event.audio = artistData.preview;
                  eventsWithData.push(event);
                }
                if (i === events.length - 1) {
                  return callback(null, eventsWithData);
                }
              });
            })(index, event));
          }
          return _results;
        }
      ], (function(_this) {
        return function(error, results) {
          return _this._dataLoaded(results);
        };
      })(this));
    };

    return App;

  })();
});

//# sourceMappingURL=app.js.map
