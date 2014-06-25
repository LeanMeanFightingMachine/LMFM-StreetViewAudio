define (require) ->

	createInfoWindow = (map, data) ->
		lastFM = data.lastFMEventData
		deezer = data.deezerArtistData

		console.log(data)

		venueImage = lastFM.venue.image[3]["#text"]

		content = ""
		content += "<img height='120' src='#{deezer.artist.picture}'> <img height='120' src='#{venueImage}'><br/>"
		content += "<strong>#{lastFM.artists.headliner}</strong> - playing at <strong>#{lastFM.venue.name}</strong> on <strong>#{lastFM.startDate}</strong><br/>"
		content += "<br/>"
		content += "<img height='64' src='#{deezer.album.cover}'><br/>"
		content += "Now playing: <strong>#{deezer.title}</strong> from <strong>#{deezer.album.title}</strong><br/>"

		infoWindow = new google.maps.InfoWindow
			position: data.location
			map: map
			content: content

		return infoWindow
