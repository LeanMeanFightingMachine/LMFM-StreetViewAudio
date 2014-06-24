define ->

	# ensure angle is between -180 and 180 degrees

	fixAngle = (angle) ->
		if angle > 180
			return angle - 360
		else if angle < -180
			return angle + 360
		else
			return angle

	# callbacks:
	#   onUpdate(distance, angle, position)

	class StreetViewWrapper

		constructor: () ->
			@enabled = false

			@panorama = null

		initialise: (@panorama) ->
			@_addEventListeners()

		setPosition: (latLng) ->
			@panorama.setPosition(latLng)

		_addEventListeners: () ->
			google.maps.event.addListener(@panorama, "position_changed", =>
				@_update()
			)

			google.maps.event.addListener(@panorama, "pov_changed", =>
				@_update()
			)

		_update: () ->
			if not @enabled
				return

			position = @panorama.getPosition()
			pov = @panorama.getPov()

			if not position or not pov
				return

			@onUpdate(position, pov.heading)

			return
