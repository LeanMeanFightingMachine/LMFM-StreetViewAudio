define(function() {
  var AUDIO_CONTEXT, AudioContext, Sound, error, mobileWebkit;
  AudioContext = window.webkitAudioContext || window.AudioContext;
  try {
    AUDIO_CONTEXT = new AudioContext();
  } catch (_error) {
    error = _error;
    console.log('Web Audio API Unsupported', error);
  }
  mobileWebkit = !!navigator.userAgent.match(/(iPad|Android)/g);
  return Sound = (function() {
    Sound.IS_SUPPORTED = !!AUDIO_CONTEXT;

    Sound.prototype.MUTED = false;

    Sound.prototype.VOLUME = 4;

    function Sound(src) {
      this.srcElement = new Audio;
      this.srcElement.loop = true;
      this.srcElement.src = src;
      this.srcElement.preload = "auto";
      this.srcElement.addEventListener('canplaythrough', (function(_this) {
        return function() {
          return _this.srcElement.play();
        };
      })(this));
      this._setupNodes();
    }

    Sound.prototype.start = function() {};

    Sound.prototype.stop = function() {};


    /*
    				CONFIG AUDIO
     */

    Sound.prototype.setDistanceAndHeading = function(distance, heading) {
      return this._updatePanner(heading, distance);
    };

    Sound.prototype._updateFilter = function(normalizedHeading) {
      var filterFreq;
      filterFreq = 44000 - (41500 * normalizedHeading);
      return this.filter.frequency.value = filterFreq;
    };

    Sound.prototype._updateGain = function(normalizedHeading) {
      var gain, volume;
      volume = this.MUTED ? 0 : this.VOLUME;
      gain = volume - ((volume / 1.4) * normalizedHeading);
      return this.gain.gain.value = gain;
    };

    Sound.prototype._updatePanner = function(heading, distance) {
      var headingRadians, x, y, z;
      headingRadians = heading * (Math.PI / 180);
      x = Math.sin(headingRadians) * distance;
      y = Math.cos(headingRadians) * distance;
      z = distance;
      return this.panner.setPosition(-x, y, z);
    };

    Sound.prototype._setupNodes = function() {
      this.sourceNode = AUDIO_CONTEXT.createMediaElementSource(this.srcElement);
      this.filter = AUDIO_CONTEXT.createBiquadFilter();
      this.filter.frequency.value = 44000;
      this.filter.type = "lowpass";
      this.panner = AUDIO_CONTEXT.createPanner();
      this.panner.distanceModel = "exponential";
      this.panner.refDistance = 50;
      this.panner.rolloffFactor = 1.2;
      this.gain = AUDIO_CONTEXT.createGain();
      this.gain.channelCount = 1;
      this.gain.gain.value = this.VOLUME;
      return this._routeNodes();
    };

    Sound.prototype._routeNodes = function() {
      this.sourceNode.connect(this.panner);
      return this.panner.connect(AUDIO_CONTEXT.destination);
    };

    return Sound;

  })();
});

//# sourceMappingURL=Sound.js.map
