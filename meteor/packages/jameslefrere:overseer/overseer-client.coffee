Meteor.startup ->
	Overseer.state = new ReactiveVar "select-app"
	UI.render Template.overseer, document.body
	return

UI.registerHelper "state", (state) ->
	Overseer.state.get() is state

UI.registerHelper "app", ->
	Overseer.db.apps.findOne appId: Session.get("appId")

Template.overseerApps.helpers
	apps: -> Overseer.db.apps.find()
	isActive: -> Session.get("appId") is @appId

Template.overseerApps.events
	"click li": ->
		if Session.get("appId") is @appId
			Session.set "appId", undefined
			Overseer.state.set "select-app"
		else
			Session.set "appId", @appId
			Overseer.state.set "manage-app"
		return

Template.overseerList.helpers
	packages: -> Overseer.db.packages.find(appId: Session.get("appId"))

AutoForm.hooks
	overseerForm:
		onSubmit: (insertDoc, updateDoc, currentDoc) ->
			@event.preventDefault()
			self = @
			selectedApp = Overseer.db.apps.findOne appId: Session.get("appId")
			console.log selectedApp
			return unless selectedApp
			Meteor.call "overseerCreatePackage", insertDoc, selectedApp, (err, res) ->
				if err
					self.done(new Error err)
				else self.done()
			return
