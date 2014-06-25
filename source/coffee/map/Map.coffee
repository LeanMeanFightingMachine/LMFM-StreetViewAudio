define ->

	# callbacks:
	#   onStreetViewOpened(latLng)

	class Map
		constructor: () ->
			@map = null
			@_moveTimeout = null

		initialise: (el, zoom) ->
			@map = new google.maps.Map(el,
				zoom: zoom
			)

			@_addEventListeners()

		setCenter: (latLng) ->
			@map.setCenter(latLng)

		_timeoutCallback: () =>
			position = @map.getCenter()

			@onMoved(position)

		_addEventListeners: () ->
			google.maps.event.addListener(@map, "center_changed", =>
				clearTimeout(@_moveTimeout)

				@_moveTimeout = setTimeout(@_timeoutCallback, 800)
			)
