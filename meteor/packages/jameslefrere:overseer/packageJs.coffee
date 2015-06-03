SSR.compileTemplate "packageJs", Assets.getText("private/package.js.html")

Template.packageJs.helpers
	list: (array) ->
		return unless array.length
		if array.length is 1
			return '"' + array[0] + '"'
		else
			return '["' + array.join('", "') + '"]'
