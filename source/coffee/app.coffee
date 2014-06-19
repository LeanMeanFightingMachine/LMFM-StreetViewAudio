define (require) ->

	onGoogleMapsReady = require("util/onGoogleMapsReady")

	lastFM = require("api/lastfm")
	deezer = require("api/deezer")
	StreetViewWrapper = require("wrapper/StreetViewWrapper")
	Sound = require("audio/Sound")


	start =
		lat: 51.514708
		long: -0.130377

	elements =
		streetView: document.querySelectorAll('.streetView')[0]

	sources = []

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
				@_loadData(@_dataLoaded)
			)

		_dataLoaded: ->
			console.log 'data loaded', sources

		_loadData: (complete) ->
			LastFM.eventsByLatLng start.lat, start.long, (eventData) =>
				for event, indexaa in eventData
					console.log indexaa
					sourceData = {}
					sourceData.location = event.venue.location["geo:point"]
					sourceData.artist = artist = event.artists.headliner

					Deezer.searchArtist encodeURI(artist), (artistData) =>
						if artistData then Deezer._get artistData.artist.tracklist, (trackData) =>
							sourceData.cues = []
							for cue in trackData.data
								sourceData.cues.push cue.preview

							console.log indexaa
							return complete() if indexaa is eventData.length
