require.config
	paths:
		"jquery": "../vendor/jquery"

	shim:
		app: ["jquery"]


require ["app"], (App) -> new App()