define(function(require) {
  var StreetViewMarker;
  return StreetViewMarker = (function() {
    function StreetViewMarker(streetView, data) {
      this.marker = new google.maps.InfoWindow({
        position: data.location,
        map: streetView,
        content: data.venue.name
      });
    }

    return StreetViewMarker;

  })();
});

//# sourceMappingURL=streetViewMarker.js.map
