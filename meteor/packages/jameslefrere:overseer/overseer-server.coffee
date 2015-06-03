
console.log @S
Overseer = @Overseer
fs = Npm.require "fs"
vm = Npm.require "vm"

mkdirSync = (path, perms) ->
	try
		fs.mkdirSync path, perms
	catch e
		throw new Meteor.Error e.code
	return

class @PackageProcessor
	self = @
	_fileIndex = 0
	_useIndex = 0
	_exportIndex = 0

	res =
		apiUse: []
		apiFiles: []
		apiExport: []
		npmDepends: []

	constructor: ->
		@describe = (options) ->
			for key, value of options
				res[key] = value
			return

		@depends = (obj) ->
			key = Object.keys(obj)[0]
			res.npmDepends.push
				name: key
				version: obj[key]

		@require = ->
			# @todo: require
			return

		@registerBuildPlugin = ->
			# @todo: registerBuildPlugin
			return

		@onTest = (func) ->
			# @todo: onTest
			return

		@onUse = (func) ->
			api =
				versionsFrom: (version) ->
					res.versionsFrom = version

				addFiles: (files, where) ->
					_processItems "_addFile", files, where

				# @todo: imply
				imply: -> return

				use: (names, where) ->
					_processItems "_addUse", names, where

				export: (variables, where) ->
					_processItems "_addExport", variables, where

			api.add_files = api.addFiles # legacy
			func(api)
			return

		# Legacy aliases
		@on_use = @onUse
		@on_test = @onTest

		@res = ->
			return res

		return

	@_addFile = (file, where) ->
		res.apiFiles.push
			name: file
			where: where
			weight: _fileIndex
		_fileIndex++
		return

	@_addExport = (variable, where) ->
		res.apiExport.push
			variable: variable
			where: where
			weight: _exportIndex
		_exportIndex++
		return

	@_addNpm = (name, version) ->
		res.npmDepends.push
			name: file
			version: version
		return

	@_addUse = (name, where) ->
		res.apiUse.push
			name: name
			where: where
			weight: _useIndex
		# @todo: handle weak, bare, versions
		_useIndex++
		return

	_processItems = (funcName, items, where) ->
		if typeof where is "string" then where = new Array where
		if typeof items isnt "string"
			for item in items
				self[funcName](item, where)
		else self[funcName](items, where)
		return


PackageProcessor = @PackageProcessor

Meteor.publish null, ->
	Overseer.db.packages.find()

Meteor.publish null, ->
	Overseer.db.apps.find()

Meteor.methods
	overlordStartup: (data) ->
		###
		# Find local packages.
		# I'm only counting those in /packages which aren't under git,
		# and are therefore likely to be part of the app.
		###
		packagesPath = "#{data.pwd}/packages"
		packagesDir = fs.readdirSync packagesPath
		naughtyList = [
			"npm-container"
		]
		for pkg in packagesDir
			unless pkg[0] is "." or pkg in naughtyList
				dir = fs.readdirSync "#{packagesPath}/#{pkg}"
				unless dir.indexOf(".git") is 0
					# Dark magic to read the package.js file
					packageJs = fs.readFileSync "#{packagesPath}/#{pkg}/package.js", "utf8"
					schmackageJs = packageJs.replace(/Package|Npm/g, "schmackage")
					processed = vm.runInThisContext "var schmackage = new PackageProcessor(); #{schmackageJs} schmackage.res();"

					# Upsert package into Overseer packages db
					processed.appId = data.appId
					Overseer.db.packages.upsert {appId: processed.appId, name: processed.name},
						$set: processed

		# Upsert the app to the Overseer apps db
		Overseer.db.apps.upsert {appId: data.appId},
			$set: data

		# Let Overlord know everything's fine
		return "Overseer connection established"

	overseerCreatePackage: (data, app) ->
		packagesDir = fs.readdirSync "#{app.pwd}/packages"
		packagePath = "#{app.pwd}/packages/#{data.name}"

		# Create the package dir unless it exists already
		mkdirSync packagePath, 0o0755 if packagesDir.indexOf(data.name) is -1

		# Create the package.js file
		fs.writeFileSync "#{packagePath}/package.js", SSR.render(Template.packageJs, data)

		# Create the dirs/files
		for file in data.apiFiles
			parsed = file.name.match(/^(.+\/)*(.+)\.(.+)$/)
			mkdirSync "#{packagePath}/#{parsed[1]}", 0o755 if parsed[1]
			fs.writeFileSync "#{packagePath}/#{file.name}", ""

		# Upsert the package to the db
		data.appId = app.appId
		Overseer.db.packages.upsert {name: data.name},
			$set: data
