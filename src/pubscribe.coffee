class EventBus

	constructor:()->
		subscriber = ()->

		@publish = (type, args...)->
			subscriber()

		@subscribe = (type, callback)->
			subscriber = callback

exports.EventBus = EventBus
