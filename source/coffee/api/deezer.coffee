
class Deezer

	@API_KEY = "14b5d40e28da8a1c3b1a66fe312b98dd"
	@API_ADDRESS = "https://api.deezer.com"

	@searchArtist: (artist, callback) ->
		request = @_requestURL('search',{q:artist})

		@_get request, (data) ->
			for artistObj in data.data
				if artistObj.artist.name is artist
					callback(artistObj)
					return
				else
					callback(false)

	@_get: (url, callback) ->
		req = new XMLHttpRequest()
		req.onload = ->
			callback(JSON.parse(req.responseText))
		req.open("GET", url, true)
		req.send()

	@_requestURL: (method, params) ->
		url = "#{@API_ADDRESS}/#{method}?"

		for key, val of params
			url += "#{key}=#{val}"

		return url