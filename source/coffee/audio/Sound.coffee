define ->

	AudioContext = window.webkitAudioContext or window.AudioContext

	try
		AUDIO_CONTEXT = new AudioContext()
	catch error
		console.log 'Web Audio API Unsupported', error

	mobileWebkit = !!navigator.userAgent.match(/(iPad|Android)/g)

	class Sound

		@IS_SUPPORTED = !!AUDIO_CONTEXT

		MUTED: false
		VOLUME: 4

		constructor: (src) ->
			@audio = new Audio
			@audio.autoplay = false
			@audio.loop = true
			@audio.src = src
			@audio.preload = "auto"

			@_setupNodes()

		start: () ->
			# start the sounds here
			@audio.play() unless !@audio.paused

		stop: () ->
			# stop the sounds here

		setDistanceAndHeading: (distance, heading) ->

			# For mobile webkit, we'll trigger the audio cue when street view has been interacted with
			# Providing: the audio buffer exists, hasnt already been started and we on mobile webkit
			#if @sourceCue.buffer? and !@sourceCue.hasStarted and mobileWebkit
				#@sourceCue.hasStarted = true
				#@sourceCue.start(0) if @ACTIVE

			#@_updateFilter(normalizedHeading)
			#@_updateGain(normalizedHeading)
			@_updatePanner(heading, distance)

		_updateFilter: (normalizedHeading) ->
			filterFreq = 44000 - (41500 * normalizedHeading)
			@filter.frequency.value = filterFreq

		_updateGain: (normalizedHeading) ->
			volume = if @MUTED then 0 else @VOLUME
			gain = volume - ((volume / 1.4) * normalizedHeading)
			@gain.gain.value = gain

		_updatePanner: (heading, distance) ->
			headingRadians = heading * (Math.PI / 180)

			x = Math.sin(headingRadians) * distance
			y = Math.cos(headingRadians) * distance
			z = distance # For some reason having a relative z helps panning smoothness

			@panner.setPosition(-x, y, z)

		_setupNodes: ->
			@sourceNode = AUDIO_CONTEXT.createMediaElementSource(@audio)

			@filter = AUDIO_CONTEXT.createBiquadFilter()
			@filter.frequency.value = 44000
			@filter.type = "lowpass"

			@panner = AUDIO_CONTEXT.createPanner()
			@panner.distanceModel = "exponential"
			@panner.refDistance = 50
			@panner.rolloffFactor = 1.2

			@gain = AUDIO_CONTEXT.createGain()
			@gain.channelCount = 1
			@gain.gain.value = @VOLUME

			@_routeNodes()

		# Route web audio nodes
		_routeNodes: ->
			@sourceNode.connect(@panner)
			#@filter.connect(@gain)
			#@gain.connect(@panner)
			@panner.connect(AUDIO_CONTEXT.destination)
