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

class FilteredEventBus

	constructor:(bus, types)->
		throwIfTypeIsNotValid = (type)->
			for oneOfTheValidTypes in types
				if type is oneOfTheValidTypes
					return
			throw new Error "Invalid event type"

		@publish = (args...)->
			throwIfTypeIsNotValid args[0]
			bus.publish.apply bus, args

		@subscribe = (type, callback)->
			throwIfTypeIsNotValid type
			bus.subscribe type, callback

		@unsubscribe = (type, callback)->
			throwIfTypeIsNotValid type
			bus.unsubscribe type, callback

camelize = (string)->
	parts = string.split new RegExp " |_|-"
	upcasedParts = parts.map (part)->
		part.substring(0, 1).toUpperCase() + part.substring 1
	upcasedParts.join ""

addMethods = (bus, type)->
	camelName = camelize type
	bus['subscribeTo'+camelName] = (callback)->
		bus.subscribe type, callback
	bus['unsubscribeFrom'+camelName] = (callback)->
		bus.unsubscribe type, callback
	bus['publish'+camelName] = (args...)->
		bus.publish.apply bus, [type].concat args

exports.EventBus = EventBus
exports.create = (args...)->
	if args.length == 0
		new EventBus
	else
		bus = new FilteredEventBus (new EventBus), args
		for eventType in args
			addMethods bus, eventType
		bus
