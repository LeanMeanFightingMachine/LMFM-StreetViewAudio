define(function() {
  var SPOTTED_DURATION, StreetViewWrapper, TARGET_ANGLE, fixAngle;
  TARGET_ANGLE = 5;
  SPOTTED_DURATION = 1200;
  fixAngle = function(angle) {
    if (angle > 180) {
      return angle - 360;
    } else if (angle < -180) {
      return angle + 360;
    } else {
      return angle;
    }
  };
  return StreetViewWrapper = (function() {
    function StreetViewWrapper() {
      this.enabled = false;
      this._customPanoramas = {};
      this._panorama = null;
      this._originalDestination = null;
      this._destination = null;
      this._isInEndPosition = false;
    }

    StreetViewWrapper.prototype.initialise = function(el) {
      this._panorama = new google.maps.StreetViewPanorama(el);
      return this._addEventListeners();
    };

    StreetViewWrapper.prototype.setLatLong = function(lat, lng) {
      var position;
      position = new google.maps.LatLng(lat, lng);
      return this.setPosition(position);
    };

    StreetViewWrapper.prototype.setPosition = function(position) {
      return this._panorama.setPosition(position);
    };

    StreetViewWrapper.prototype._addEventListeners = function() {
      google.maps.event.addListener(this._panorama, "position_changed", (function(_this) {
        return function() {
          return _this._update();
        };
      })(this));
      return google.maps.event.addListener(this._panorama, "pov_changed", (function(_this) {
        return function() {
          return _this._update();
        };
      })(this));
    };

    StreetViewWrapper.prototype._update = function() {
      var destinationHeading, distance, heading, pitch, position, pov;
      if (!this.enabled) {
        return;
      }
      position = this._panorama.getPosition();
      pov = this._panorama.getPov();
      if (!position || !pov) {
        return;
      }
      this.onUpdate(position, pov.heading);
      return;
      distance = google.maps.geometry.spherical.computeDistanceBetween(position, this._destination);
      destinationHeading = google.maps.geometry.spherical.computeHeading(position, this._destination);
      heading = fixAngle(pov.heading - destinationHeading);
      pitch = pov.pitch;
      return this.onUpdate(distance, heading, position, pov.heading);
    };

    return StreetViewWrapper;

  })();
});

//# sourceMappingURL=StreetViewWrapper.js.map
