define () ->

	LastFM =
		API_KEY: "14b5d40e28da8a1c3b1a66fe312b98dd"
		API_ADDRESS: "http://ws.audioscrobbler.com/2.0/"

		radioByArtist: (artist, callback) ->
			request = requestURL('radio.search',{name:artist})
			@_get request, (data) ->
				callback(data.events.event)

		eventsByLatLng: (params, callback) ->
			request = @_requestURL('geo.getevents', params)

			@_get request, (data) ->
				if not data.events
					console.log("no lastfm events here")

					callback([])
				else
					callback(data.events.event)

		_get: (url, callback) ->
			req = new XMLHttpRequest()
			req.onload = ->
				callback(JSON.parse(req.responseText))
			req.open("GET", url, true)
			req.send()

		_requestURL: (method, params) ->
			url = "#{@API_ADDRESS}?method=#{method}&format=json"

			for key, val of params
				url += "&#{key}=#{val}"

			return url += "&api_key=#{@API_KEY}"
