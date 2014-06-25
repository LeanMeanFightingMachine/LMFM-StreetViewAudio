define (require) ->

	class StreetViewMarker

		constructor: (streetView, map, data) ->
			lastFM = data.lastFMEventData
			deezer = data.deezerArtistData

			content =  "#{lastFM.artists.headliner}</br>"
			content += "<a href='#{lastFM.url}' target='_blank'>#{lastFM.startDate} at #{lastFM.venue.name}</a><br/>"
			content += "Now playing: <a href='#{deezer.link}' target='_blank'><i>#{deezer.title}</i> from <i>#{deezer.album.title}</i></a>"

			@position = data.location

			console.log("creating marker at", @position.toString())

			@marker = new google.maps.InfoWindow
				position: data.location
				map: streetView
				content: content

			@markerMap = new google.maps.Marker
				position: data.location
				map: map
				title: lastFM.artists.headliner

		remove: ->
			console.log("removing marker")

			@marker.close()
			@markerMap.setMap(null)
