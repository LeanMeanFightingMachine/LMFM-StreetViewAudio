exec = require("child_process").exec

module.exports = (grunt) ->

	# Load tasks
	Object.keys(require("./package.json").dependencies).forEach (dep) -> grunt.loadNpmTasks dep if dep.substring(0,6) is "grunt-"

	# Project configuration
	grunt.initConfig

		# Clean directories
		clean:
			source: ["source/js"]

			release: ["release"]

		# Compile CoffeeScript
		coffee:
			compile:
				options:
					bare: true
					sourceMap: true
				expand: true
				cwd: "source/coffee"
				src: ["**/*.coffee"]
				dest: "source/js"
				ext: ".js" 

		# Compile Stylus
		stylus:
			source:
				options:
					compress: false
					urlfunc: "embed"
				files:
					"source/style/main.css": "source/style/main.styl"

			release:
				options:
					compress: true
					urlfunc: "embed"
				files:
					"release/style/main.css": "source/style/main.styl"

		# Watch for changes
		watch:
			coffee:
				files: ["source/coffee/**/*.coffee"]
				options:
					spawn: false

			stylus:
				files: ["source/style/**/*.styl"]
				options:
					spawn: false
				tasks: ["stylus:source", "playSound"]

		# Build the release version
		requirejs:
			compile:
				options:
					name: "main"
					mainConfigFile: "source/js/main.js"
					baseUrl: "source/js"
					out: "release/js/main.js"
					optimizeCss: "none"
					skipDirOptimize: true
					preserveLicenseComments: false
					pragmasOnSave:
						excludeHbsParser: true
						excludeHbs: true
						excludeAfterBuild: true

		# Copy files
		copy:
			requirejs:
				expand:true, cwd:"source/vendor", src:["require.js"], dest:"source/js"

			release:
				expand:true, cwd:"source", src:["**", "**/.htaccess", "!**/coffee/**", "!**/js/**", "!**/style/**", "!**/template/**", "!**/vendor/**", "!**/bootstrap.html", "js/require.js"], dest:"release"

		# Notify messages
		notify:
			source:
				options:
					title: "lastfm-streetview"
					message: "Compilation completed and now watching for changes..."

			release:
				options:
					title: "lastfm-streetview"
					message: "Build completed."

			watch:
				options:
					title: "lastfm-streetview"
					message: "File updated."

			failed:
				options:
					title: "lastfm-streetview"
					message: "Error on the compilation"

	grunt.registerTask "playSound", -> exec("afplay /System/Library/Sounds/Tink.aiff -v 0.5")

	grunt.registerTask "hasFailed", ->
		if grunt.fail.errorcount > 0
			grunt.fail.errorcount = 0
			grunt.task.run "notify:failed"
		else
			exec("afplay /System/Library/Sounds/Tink.aiff -v 0.5")

	# Watch for file changes
	grunt.event.on "watch", (action, filepath) ->
		# Return if it's not a Coffee file
		return if filepath.indexOf(".coffee") < 0

		# Get the path of the coffee files
		source_coffee = "source/coffee"
		source_js = "source/js"
		file_name = filepath.split("#{source_coffee}/").join("")
		notification = null
		tasks = []

		grunt.option "force", true

		if action is "deleted"
			# Change the coffee path to the js path
			# And also change the "coffee" extension to "js"
			filepath = filepath.split(source_coffee).join(source_js)
			filepath = filepath.split(".coffee").join(".js")
			notification = "The file #{file_name} was deleted."
			tasks = ["clean", "notify:watch"]

			# Delete a specific file and notify that the file was deleted
			grunt.config ["clean"], [filepath]
			grunt.config ["notify", "watch", "options", "message"], notification
			grunt.task.run tasks
		else
			# Remove the path from the file that was changed
			filepath = filepath.split(source_coffee).join("")
			filepath = filepath.slice(1, filepath.length) if filepath.indexOf("/") is 0
			notification = if action is "changed" then "The file #{file_name} was updated!" else "The file #{file_name} was created!"
			tasks = ["coffee", "hasFailed"]

			grunt.config ["notify", "watch", "options", "message"], notification
			grunt.config ["notify", "failed", "options", "message"], "Failed to compile #{file_name}"
			grunt.config ["coffee", "compile", "src"], filepath

			# Run the the CoffeeScript and check for errors
			grunt.task.run tasks

	grunt.registerTask "default", ["clean:source","copy:requirejs","coffee","stylus:source","notify:source","playSound","watch"]

	grunt.registerTask "build", ["clean","copy:requirejs","coffee","stylus","requirejs","copy:release","notify:release","playSound"]
	