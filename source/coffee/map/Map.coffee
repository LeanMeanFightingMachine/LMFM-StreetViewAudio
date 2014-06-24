define ->

	# callbacks:
	#   onStreetViewOpened(latLng)

	class Map
		constructor: () ->
			@streetView = null

			@_map = null
			@_isFirstPositionChange = true

		initialise: (el, zoom) ->
			@_map = new google.maps.Map(el,
				zoom: zoom
			)

			@streetView = @_map.getStreetView()

			@_addEventListeners()

		setCenter: (latLng) ->
			@_map.setCenter(latLng)

		_addEventListeners: () ->
			google.maps.event.addListener(@_map.getStreetView(), "position_changed", =>
				if @_isFirstPositionChange
					@_isFirstPositionChange = false

					position = @streetView.getPosition()

					@onStreetViewOpened(position)
			)

			google.maps.event.addListener(@_map.getStreetView(), "closeclick", =>
				@_isFirstPositionChange = true
			)
