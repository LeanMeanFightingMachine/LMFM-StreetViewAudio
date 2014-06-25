define ->

	# callbacks:
	#   onStreetViewOpened(latLng)

	class Map
		constructor: () ->
			@_map = null
			@_moveTimeout = null

		initialise: (el, zoom) ->
			@_map = new google.maps.Map(el,
				zoom: zoom
			)

			@_addEventListeners()

		setCenter: (latLng) ->
			@_map.setCenter(latLng)

		_timeoutCallback: () =>
			position = @_map.getCenter()

			@onMoved(position)

		_addEventListeners: () ->
			google.maps.event.addListener(@_map, "center_changed", =>
				clearTimeout(@_moveTimeout)

				@_moveTimeout = setTimeout(@_timeoutCallback, 800)
			)
