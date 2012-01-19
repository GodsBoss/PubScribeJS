class EventBus

	constructor:()->
		subscribers = {}

		@publish = (type, args...)->
			for subscriber in subscribers[type] or {}
				subscriber()

		@subscribe = (type, callback)->
			if not subscribers[type]
				subscribers[type] = []
			subscribers[type].push callback

exports.EventBus = EventBus
