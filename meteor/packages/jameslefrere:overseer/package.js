Package.describe({
	name: "jameslefrere:overseer",
	version: "0.1.0",
	// Brief, one-line summary of the package.
	summary: "A development package to manage local packages",
	// URL to the Git repository containing the source code for this package.
	git: "",
	// By default, Meteor will default to using README.md for documentation.
	// To avoid submitting documentation, set this field to null.
	documentation: "README.md"
});

Package.onUse(function(api) {
	api.versionsFrom("1.1.0.2");
	api.use([
		"mongo",
		"coffeescript",
		"less",
		"templating",
		"reactive-var",
		"aldeed:collection2@2.3.3",
		"aldeed:simple-schema@1.3.3",
		"aldeed:autoform@5.3.0",
		"meteorhacks:ssr@2.1.1"
		]);
	api.addFiles("lib/overseer.coffee");
	api.addFiles("private/package.js.html", "server", {isAsset: true});
	api.addFiles([
		"packageJs.coffee",
		"overseer-server.coffee"
	], "server");
	api.addFiles([
		"lib/overseer.html",
		"overseer-client.coffee",
		"overseer.less",
		"flexboxgrid.min.css"
		], "client");
	// api.addFiles("export.js");
	// api.export("Overseer");
});
