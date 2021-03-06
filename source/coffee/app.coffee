define (require) ->

	onGoogleMapsReady = require("util/onGoogleMapsReady")
	async = require("../vendor/async")
	LastFM = require("api/LastFM")
	Deezer = require("api/Deezer")
	Map = require("map/Map")
	getDOMElementsOverlayClass = require("overlay/getDOMElementsOverlayClass")
	StreetViewWrapper = require("streetView/StreetViewWrapper")
	createInfoWindow = require("streetView/createInfoWindow")
	Sound = require("audio/Sound")

	# start map at Camden Town
	mapStartPosition =
		lat: 51.539011
		lng: -0.142555

	config =
		distance: 6 # in kilometres
		lastFMResultsMax: 15
		mapZoom: 15

	elements =
		map: document.querySelector(".map")
		streetViewBackground: document.querySelector(".street-view-background")
		streetView: document.querySelector(".street-view")

	fixAngle = (angle) ->
		if angle > 180
			return angle - 360
		else if angle < -180
			return angle + 360
		else
			return angle

	class App

		constructor: ->
			@map = new Map()
			@streetView = new StreetViewWrapper()

			@domElementsOverlay = null

			@sources = []
			@sourcesByLatLng = {}

			elements.streetViewBackground.addEventListener("click", (event) =>
				if event.target == event.currentTarget
					elements.streetView.classList.add("is-hidden")
					elements.streetViewBackground.classList.add("is-hidden")

					@streetView.close()
			)

			@map.onMoved = (latLng) =>
				for i in [@sources.length - 1..0] by -1
					source = @sources[i]

					distance = google.maps.geometry.spherical.computeDistanceBetween(latLng, source.location)

					if distance > config.distance * 1000
						source.infoWindow.close()

						@domElementsOverlay.remove(source.overlayElement)

						@sources.splice(i, 1)

						@sourcesByLatLng[latLng] = false

				@_loadEvents(latLng)

			@streetView.onStreetViewOpened = (latLng) =>
				elements.streetView.classList.remove("is-hidden")
				elements.streetViewBackground.classList.remove("is-hidden")

				for source in @sources
					source.sound.start()

			@streetView.onClosed = =>
				for source in @sources
					source.sound.stop()

			@streetView.onUpdate = @_updateSounds.bind(@)

			onGoogleMapsReady( =>
				@map.initialise(elements.map, config.mapZoom)
				@map.setCenter(mapStartPosition)

				@domElementsOverlay = new (getDOMElementsOverlayClass())("last-fm-markers")
				@domElementsOverlay.setMap(@map.map)

				@streetView.initialise(elements.streetView)
				@map.map.setStreetView(@streetView.panorama)
			)

		_updateSounds: (position, heading) ->
			#console.log position, heading

			for source in @sources
				headingToSource = google.maps.geometry.spherical.computeHeading(position, source.location)
				normalizedHeading = fixAngle(heading - headingToSource)
				distance = google.maps.geometry.spherical.computeDistanceBetween(position, source.location)
				source.sound?.setDistanceAndHeading distance, normalizedHeading

		_dataLoaded: (data) ->
			sources = data

			for source in sources
				source.sound = new Sound(source.deezerArtistData.preview)
				source.infoWindow = createInfoWindow(@streetView.panorama, source)
				source.overlayElement = document.createElement("div")
				source.overlayElement.className = "last-fm-marker"

				@domElementsOverlay.add(source.overlayElement, source.location)

			@sources.push.apply(@sources, sources)

			@streetView.enabled = true

		_loadEvents: (latLng) ->
			sourcesByLatLng = @sourcesByLatLng

			async.waterfall([

				(callback) ->
					events = []

					LastFM.eventsByLatLng {lat:latLng.lat(), long:latLng.lng(), distance:config.distance, limit: config.lastFMResultsMax}, (eventData) ->
						for event in eventData
							latLng = new google.maps.LatLng(event.venue.location["geo:point"]["geo:lat"], event.venue.location["geo:point"]["geo:long"])

							if sourcesByLatLng[latLng]
								continue

							sourcesByLatLng[latLng] = true

							sourceData = {}
							sourceData.lastFMEventData = event
							sourceData.location = latLng

							events.push sourceData

						callback null, events

				(events, callback) ->
					eventsWithData = []

					for event, index in events
						((i, event) ->
							Deezer.searchArtist event.lastFMEventData.artists.headliner, (artistData) ->
								if artistData
									event.deezerArtistData = artistData
									eventsWithData.push event

								callback(null, eventsWithData) if i is events.length-1
						)(index, event)

				],

				(error, results) =>
					@_dataLoaded(results)

			)
