define (require) ->

	onGoogleMapsReady = require("util/onGoogleMapsReady")

	async = require("../vendor/async")
	lastFM = require("api/lastfm")
	Deezer = require("api/deezer")
	StreetViewWrapper = require("wrapper/StreetViewWrapper")
	Sound = require("audio/Sound")

	# GUMF
	start =
		lat: 50.82104
		long: -0.1356339

	elements =
		streetView: document.querySelectorAll('.streetView')[0]

	sources = []

	fixAngle = (angle) ->
		if angle > 180
			return angle - 360
		else if angle < -180
			return angle + 360
		else
			return angle

	###
		get lastfm radio streams for each artists events
		add params to new Sound constructor
			lat long
			radio stream url
		when street view updates update each source with streetview position/heading etc
	###

	class App

		constructor: ->
			console.log "Hello World :)"
			@streetView = new StreetViewWrapper()

			onGoogleMapsReady( =>
				@streetView.initialise(elements.streetView)
				@streetView.setLatLong(start.lat, start.long)
				@streetView.onUpdate = @_update
				@_loadEvents()
			)

		_update: (position, heading) ->
			#console.log position, heading

			for source in sources
				headingToSource = google.maps.geometry.spherical.computeHeading(position, source.location)
				normalizedHeading = fixAngle(heading - headingToSource)
				distance = google.maps.geometry.spherical.computeDistanceBetween(position, source.location)
				source.Sound?.setDistanceAndHeading distance, normalizedHeading
				source.Sound?.start()



		_dataLoaded: (data) ->
			sources = data
			for source in sources
				source.Sound = new Sound(source.audio)
				console.log source.venue.name

			@streetView.enabled = true


		_loadEvents: () ->
			async.waterfall([

				(callback) ->
					events = []

					LastFM.eventsByLatLng {lat:start.lat, long:start.long, distance:1, limit: 5}, (eventData) ->
						for event in eventData
							sourceData = {}
							sourceData.venue = event.venue
							sourceData.location = new google.maps.LatLng(event.venue.location["geo:point"]["geo:lat"], event.venue.location["geo:point"]["geo:long"])
							sourceData.artist = event.artists.headliner

							events.push sourceData
						callback null, events

				(events, callback) ->
					eventsWithData = []

					for event, index in events
						((i, event) ->
							Deezer.searchArtist event.artist, (artistData) ->
								if artistData
									event.audio = artistData.preview
									eventsWithData.push event

								callback(null, eventsWithData) if i is events.length-1
						)(index, event)

				],

				(error, results) =>
					@_dataLoaded(results)

			)