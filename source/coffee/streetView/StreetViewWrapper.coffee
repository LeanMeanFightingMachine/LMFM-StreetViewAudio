define ->

	TARGET_ANGLE = 5 # must be looking x degrees from the child to 'see' it
	SPOTTED_DURATION = 1200 # time needed to look at child to see it

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

			@_customPanoramas = {}

			@panorama = null
			@_originalDestination = null
			@_destination = null
			@_isInEndPosition = false

		initialise: (el) ->
			@panorama = new google.maps.StreetViewPanorama(el)

			@_addEventListeners()

		setLatLong: (lat, lng) ->
			position = new google.maps.LatLng(lat,lng)
			@setPosition(position)

		setPosition: (position) ->
			@panorama.setPosition(position)

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

			distance = google.maps.geometry.spherical.computeDistanceBetween(position, @_destination)

			destinationHeading = google.maps.geometry.spherical.computeHeading(position, @_destination)

			heading = fixAngle(pov.heading - destinationHeading)
			pitch = pov.pitch

			@onUpdate(distance, heading, position, pov.heading)

