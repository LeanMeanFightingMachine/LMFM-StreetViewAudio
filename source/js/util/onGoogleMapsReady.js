define([], function() {
  var GOOGLE_MAPS_API_KEY, callbacks, googleMapsLoaded, onGoogleMapsReady, script;
  GOOGLE_MAPS_API_KEY = "AIzaSyBOm7bWqAZsoBsXS2yQqXBaAlHXegWJxKM";
  googleMapsLoaded = false;
  callbacks = [];
  onGoogleMapsReady = function(callback) {
    if (googleMapsLoaded) {
      return callback();
    } else {
      return callbacks.push(callback);
    }
  };
  script = document.createElement("script");
  script.type = "text/javascript";
  script.src = "https://maps.googleapis.com/maps/api/js?sensor=false&libraries=geometry&callback=_onGoogleMapsReady&key=" + GOOGLE_MAPS_API_KEY;
  window._onGoogleMapsReady = function() {
    googleMapsLoaded = true;
    callbacks.forEach(function(callback) {
      return callback();
    });
    return callbacks.length = 0;
  };
  document.body.appendChild(script);
  return onGoogleMapsReady;
});

//# sourceMappingURL=onGoogleMapsReady.js.map
