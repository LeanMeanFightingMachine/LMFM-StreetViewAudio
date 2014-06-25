define (require) ->

	createInfoWindow = (map, data) ->
			lastFM = data.lastFMEventData
			deezer = data.deezerArtistData

			content =  "#{lastFM.artists.headliner}</br>"
			content += "<a href='#{lastFM.url}' target='_blank'>#{lastFM.startDate} at #{lastFM.venue.name}</a><br/>"
			content += "Now playing: <a href='#{deezer.link}' target='_blank'><i>#{deezer.title}</i> from <i>#{deezer.album.title}</i></a>"

			infoWindow = new google.maps.InfoWindow
				position: data.location
				map: map
				content: content

			return infoWindow
