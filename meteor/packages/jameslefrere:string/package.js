Package.describe({
	name: "jameslefrere:string",
	version: "0.1.0",
	summary: "Working around a SimpleSchema issue",
});

Package.onUse(function(api) {
	api.versionsFrom("1.1.0.2");
	api.addFiles("lib/string.js");
	api.export("S");
});
