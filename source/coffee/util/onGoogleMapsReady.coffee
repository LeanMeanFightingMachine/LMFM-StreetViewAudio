define([], () ->

	GOOGLE_MAPS_API_KEY = "AIzaSyBOm7bWqAZsoBsXS2yQqXBaAlHXegWJxKM"

	googleMapsLoaded = false
	callbacks = []

	onGoogleMapsReady = (callback) ->
		if googleMapsLoaded
			callback()
		else
			callbacks.push(callback)

	script = document.createElement("script")
	script.type = "text/javascript"
	script.src = "https://maps.googleapis.com/maps/api/js?sensor=false&libraries=geometry&callback=_onGoogleMapsReady&key=" + GOOGLE_MAPS_API_KEY

	window._onGoogleMapsReady = ->
		googleMapsLoaded = true

		callbacks.forEach((callback) ->
			callback()
		)

		callbacks.length = 0

	document.body.appendChild(script)

	return onGoogleMapsReady

)
