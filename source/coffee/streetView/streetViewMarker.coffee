define (require) ->

	class StreetViewMarker

		constructor: (streetView, data) ->
			@marker = new google.maps.InfoWindow
				position: data.location
				map: streetView
				content: data.venue.name
