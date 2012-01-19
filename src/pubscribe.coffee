class EventBus

	constructor:()->
		@publish = (type, args...)->
		@subscribe = (type, callback)->

exports.EventBus = EventBus
