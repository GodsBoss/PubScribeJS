class EventBus

	constructor:()->
		subscribers = {}

		@publish = (type, args...)->
			for subscriber in subscribers[type] or {}
				try
					subscriber.apply null, args
				catch e
			@

		@subscribe = (type, callback)->
			subscribers[type] ?= []
			return @ for subscriber in subscribers[type] when subscriber is callback
			subscribers[type].push callback
			@

		@unsubscribe = (type, callback)->
			for subscriber, index in subscribers[type] or {} when subscriber is callback
				subscribers[type][index] = subscribers[type][0]
				subscribers[type].shift()
				return @
			@

class FilteredEventBus

	constructor:(bus, types)->
		throwIfTypeIsNotValid = (type)->
			return for oneOfTheValidTypes in types when type is oneOfTheValidTypes
			throw new Error "Invalid event type"

		@publish = (args...)->
			throwIfTypeIsNotValid args[0]
			bus.publish.apply bus, args
			@

		@subscribe = (type, callback)->
			throwIfTypeIsNotValid type
			bus.subscribe type, callback
			@

		@unsubscribe = (type, callback)->
			throwIfTypeIsNotValid type
			bus.unsubscribe type, callback
			@

separatorRegExp = new RegExp " |_|-"

upcaseFirstChar = (string)->
	string.substring(0, 1).toUpperCase() + string.substring 1

camelize = (string)->
	parts = string.split separatorRegExp
	upcasedParts = parts.map upcaseFirstChar
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

exports.FilteredEventBus = FilteredEventBus

exports.create = (args...)->
	if args.length == 0
		new EventBus
	else
		bus = new FilteredEventBus (new EventBus), args
		addMethods bus, eventType for eventType in args
		bus
