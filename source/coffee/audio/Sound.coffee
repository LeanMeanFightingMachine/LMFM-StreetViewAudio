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
			@srcElement = new Audio
			@srcElement.loop = true
			@srcElement.src = src

			@_createNodes()

		start: () ->
			# start the sounds here

		stop: () ->
			# stop the sounds here


		###
				CONFIG AUDIO
		###

		setDistanceAndHeading: (distance, heading, normalizedHeading) ->

			# For mobile webkit, we'll trigger the audio cue when street view has been interacted with
			# Providing: the audio buffer exists, hasnt already been started and we on mobile webkit
			#if @sourceCue.buffer? and !@sourceCue.hasStarted and mobileWebkit
				#@sourceCue.hasStarted = true
				#@sourceCue.start(0) if @ACTIVE

			@_updateFilter(normalizedHeading)
			@_updateGain(normalizedHeading)
			@_updatePanner(heading, distance)

		_updateFilter: (normalizedHeading) ->
			filterFreq = 44000 - (41500 * normalizedHeading)
			@filter.frequency.value = masterFilterFreq

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

		_createNodes: ->

			@filter = AUDIO_CONTEXT.createBiquadFilter()
			@filter.frequency.value = 44000
			@filter.type = "lowpass"

			@panner = AUDIO_CONTEXT.createPanner()

			@gain = AUDIO_CONTEXT.createGain()
			@gain.channelCount = 1
			@gain.gain.value = @VOLUME


		# Route web audio nodes
		_routeNodes: ->
			@filter.connect(@gain)
			@gain.connect(@panner)
			@panner.connect(AUDIO_CONTEXT.destination)

