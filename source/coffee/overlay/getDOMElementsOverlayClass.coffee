define ->

	class Child
		constructor: (@element, @latLng) ->

	OverlayDOMChildren = null

	# create the class dynamically (google.maps.OverlayView will be undefined when loaded)

	getDOMElementsOverlayClass = ->

		if not OverlayDOMChildren
			class OverlayDOMChildren extends google.maps.OverlayView
				constructor: (className, @_pane="mapPane") ->
					@element = document.createElement("div")
					@element.className = className

					@children = []

				onAdd: ->
					@getPanes()[@_pane].appendChild(@element)

				draw: ->
					@_positionChildren()

				add: (element, latLng) ->
					child = new Child(element, latLng)

					@children.push(child)

					projection = this.getProjection()

					if projection
						@_positionChild(projection, child)

					@element.appendChild(element)

				remove: (element) ->
					@element.removeChild(element)

				show: ->
					@element.classList.remove("is-hidden")

				hide: ->
					@element.classList.add("is-hidden")

				_positionChildren: () ->
					projection = this.getProjection()

					@_positionChild(projection, child) for child in @children

				_positionChild: (projection, child) ->
					pixelPosition = projection.fromLatLngToDivPixel(child.latLng)

					if (!pixelPosition)
						return

					element = child.element
					styleValue = "translate(-50%, -50%) translate(#{pixelPosition.x}px, #{pixelPosition.y}px)"

					element.style.WebkitTransform = styleValue
					element.style.MozTransform = styleValue
					element.style.oTransform = styleValue
					element.style.transform = styleValue
					element.style.msTransform = styleValue

		return OverlayDOMChildren
