class EventBus

	constructor:()->
		subscribers = {}

		@publish = (type, args...)->
			for subscriber in subscribers[type] or {}
				try
					subscriber.apply null, args
				catch e

		@subscribe = (type, callback)->
			if not subscribers[type]
				subscribers[type] = []
			for subscriber in subscribers[type]
				if subscriber == callback
					return
			subscribers[type].push callback

		@unsubscribe = (type, callback)->
			for subscriber, index in subscribers[type] or {}
				if subscriber == callback
					subscribers[type][index] = subscribers[0]
					subscribers[type].shift()
					return

exports.EventBus = EventBus
