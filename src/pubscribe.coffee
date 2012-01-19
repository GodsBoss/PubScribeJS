class EventBus

	constructor:()->
		subscribers = []

		@publish = (type, args...)->
			for subscriber in subscribers
				subscriber()

		@subscribe = (type, callback)->
			subscribers.push callback

exports.EventBus = EventBus
