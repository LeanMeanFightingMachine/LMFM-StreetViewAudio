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

			@_panorama = null
			@_originalDestination = null
			@_destination = null
			@_isInEndPosition = false

		initialise: (el) ->
			@_panorama = new google.maps.StreetViewPanorama(el)

			@_addEventListeners()

		setLatLong: (lat, lng) ->
			position = new google.maps.LatLng(lat,lng)
			@setPosition(position)

		setPosition: (position) ->
			@_panorama.setPosition(position)

		_addEventListeners: () ->
			google.maps.event.addListener(@_panorama, "position_changed", =>
				@_update()
			)

			google.maps.event.addListener(@_panorama, "pov_changed", =>
				@_update()
			)

		_update: () ->
			if not @enabled
				return

			position = @_panorama.getPosition()

			if not position
				return

			distance = google.maps.geometry.spherical.computeDistanceBetween(position, @_destination)

			destinationHeading = google.maps.geometry.spherical.computeHeading(position, @_destination)

			pov = @_panorama.getPov()

			heading = fixAngle(pov.heading - destinationHeading)
			pitch = pov.pitch

			@onUpdate(distance, heading, position, pov.heading)

