@Overseer =
	db: {}
	schema: {}

Overseer = @Overseer

Overseer.schema.app = new SimpleSchema
	appId:
		type: String
	pwd:
		type: String
	rootUrl:
		type: String
	mongoUrl:
		type: String
	friendlyName:
		type: String
		optional: true

Overseer.db.apps = new Mongo.Collection "apps"
Overseer.db.apps.attachSchema Overseer.schema.app

Overseer.schema.apiUse = new SimpleSchema
	name:
		type: String
		autoform:
			label: false
			placeholder: "Package name"
# version
	where:
		type: [String]
		optional: true
		allowedValues: ["client", "server", "web", "web.browser", "web.cordova"]
		autoform:
			noselect: true
			label: false
			placeholder: "Where"
	weight:
		type: Number
		optional: true
		autoform:
			omit: true

Overseer.schema.npmDepends = new SimpleSchema
	name:
		type: String
		autoform:
			label: false
			placeholder: "Module name"
			class: "inline"
	version:
		type: String
		autoform:
			label: false
			placeholder: "Version"
			class: "inline"

Overseer.schema.apiExport = new SimpleSchema
	variable:
		type: String
		autoform:
			label: false
			placeholder: "Variable"
	where:
		type: [String]
		optional: true
		allowedValues: ["client", "server", "web", "web.browser", "web.cordova"]
		autoform:
			noselect: true
			label: false
			placeholder: "Where"

Overseer.schema.apiFile = new SimpleSchema
	name:
		type: String
		autoform:
			label: false
			placeholder: "Filename (including optional path)"
	where:
		type: [String]
		optional: true
		allowedValues: ["client", "server", "web", "web.browser", "web.cordova"]
		autoform:
			noselect: true
			label: false
			placeholder: "Where"
	weight:
		type: Number
		optional: true
		autoform:
			omit: true

Overseer.schema.package = new SimpleSchema
	name:
		type: String
	summary:
		type: String
		optional: true
	version:
		type: String
		optional: true
		defaultValue: "0.0.1"
	git:
		type: String
		optional: true
	documentation:
		type: String
		optional: true
	versionsFrom:
		type: String
		optional: true
		defaultValue: "1.1.0.2"
	debugOnly:
		type: Boolean
		optional: true
		defaultValue: false
	apiFiles:
		type: [Overseer.schema.apiFile]
		optional: true
		label: "File"
	apiUse:
		type: [Overseer.schema.apiUse]
		optional: true
		label: "Package"
	apiExport:
		type: [Overseer.schema.apiExport]
		optional: true
		label: "Variable"
	npmDepends:
		type: [Overseer.schema.npmDepends]
		optional: true
		label: "Module"
	appId:
		type: String
		optional: true
		autoform:
			omit: true

Overseer.db.packages = new Mongo.Collection "packages"
Overseer.db.packages.attachSchema Overseer.schema.package
