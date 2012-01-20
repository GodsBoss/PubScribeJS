pubsub = require "../src/pubscribe"

describe "Simple Event bus", ()->

	bus = null

	beforeEach ()->
		bus = pubsub.create()

	it "is easily constructed.", ()->

	it "lets clients publish events.", ()->

		bus.publish "foo", ()->

	it "lets client subscribe to events.", ()->

		bus.subscribe "foo", ()->

	it "notifies a client of events they subscribed to.", ()->

		notified = false

		notify = ()->
			notified = true

		bus.subscribe "foo", notify
		bus.publish "foo"

		expect(notified).toBeTruthy()

	it "notifies all clients of events they subscribed to.", ()->

		notified = [false, false]

		notify1 = ()->
			notified[0] = true

		notify2 = ()->
			notified[1] = true

		bus.subscribe "foo", notify1
		bus.subscribe "foo", notify2

		bus.publish "foo"

		expect(notified).toEqual [true, true]

	it "does not notify clients about events they did not subscribe to.", ()->

		notified = [false, false]

		notify1 = ()->
			notified[0] = true

		notify2 = ()->
			notified[1] = true

		bus.subscribe "foo", notify1
		bus.subscribe "bar", notify2
		bus.publish "foo"

		expect(notified).toEqual [true, false]

	it "passes arguments to subscribers.", ()->

		publishedArgs = [8, "bar", true]
		argsSubscribersAreCalledWith = undefined

		callback = (args...)->
			argsSubscribersAreCalledWith = args

		bus.subscribe "foo", callback
		bus.publish.apply null, ["foo"].concat publishedArgs

		expect(argsSubscribersAreCalledWith).toEqual publishedArgs

	it "prevents multi-subscribers from being called multiple times.", ()->

		calls = 0

		notify = ()->
			calls++

		bus.subscribe "bar", notify
		bus.subscribe "bar", notify
		bus.publish "bar"

		expect(calls).toEqual 1

	it "lets subscribers unsubscribe from events.", ()->

		called = false

		notify = ()->
			called = true

		bus.subscribe "baz", notify
		bus.unsubscribe "baz", notify
		bus.publish "baz"

		expect(called).toBeFalsy()

	it "ignores exceptions thrown by subscribers.", ()->

		called = false

		throwingSubscriber = ()->
			throw new Error("I am an error!")

		notify = ()->
			called = true

		bus.subscribe "bar", throwingSubscriber
		bus.subscribe "bar", notify

		publish = ()->
			bus.publish "bar"

		expect(publish).not.toThrow "I am an error!"

	it "is chainable.", ()->

		expect(bus.publish "foo").toEqual bus
		expect(bus.subscribe "foo", ()->).toEqual bus
		expect(bus.unsubscribe "foo", ()->).toEqual bus

describe "Filtered event bus", ()->

	bus = null

	beforeEach ()->
		bus = pubsub.create "foo"

	it "does not allow non-existent events to be published.", ()->

		publishInvalidEvent = ()->
			bus.publish "bar"

		expect(publishInvalidEvent).toThrow "Invalid event type"

	it "does not allow subscription to non-existent events.", ()->

		subscribeToUnknownEventType = ()->
			bus.subscribe "bar", ()->

		expect(subscribeToUnknownEventType).toThrow "Invalid event type"

	it "does not allow unsubscribing from non-existent events.", ()->

		unsubscribeFromUnknownEventType = ()->
			bus.unsubscribe "bar", ()->

		expect(unsubscribeFromUnknownEventType).toThrow "Invalid event type"

	it "publishes valid events to all subscribers.", ()->

		notified = [false, false]

		notify1 = ()->
			notified[0] = true

		notify2 = ()->
			notified[1] = true

		bus.subscribe "foo", notify1
		bus.subscribe "foo", notify2
		bus.publish "foo"

		expect(notified).toEqual [true, true]

	it "publishes no events to subscribers which unsubscribed.", ()->

		notified = false

		notify = ()->
			notified = true

		bus.subscribe "foo", notify
		bus.unsubscribe "foo", notify
		bus.publish "foo"

		expect(notified).toBeFalsy()

	it "Creates additional convenience methods.", ()->

		notified = [false, false]

		notify1 = (args...)->
			notified[0] = args

		notify2 = (args...)->
			notified[1] = args

		bus.subscribeToFoo notify1
		bus.subscribeToFoo notify2
		bus.unsubscribeFromFoo notify1
		bus.publishFoo 4, true, "yes"

		expect(notified).toEqual [false, [4, true, "yes"]]

	it "'s convenience methods are camelized versions of the event types.", ()->

		types = ["type with spaces", "use_underscores", "with-hyphens"]

		bus = pubsub.create.apply pubsub, types

		publishAllTypes = ()->
			bus.publishTypeWithSpaces()
			bus.publishUseUnderscores()
			bus.publishWithHyphens()

		subscribeToAllTypes = ()->
			bus.subscribeToTypeWithSpaces ()->
			bus.subscribeToUseUnderscores ()->
			bus.subscribeToWithHyphens ()->

		unsubscribeFromAllTypes = ()->
			bus.unsubscribeFromTypeWithSpaces ()->
			bus.unsubscribeFromUseUnderscores ()->
			bus.unsubscribeFromWithHyphens ()->

		usingConvenienceMethods = ()->
			publishAllTypes()
			subscribeToAllTypes()
			unsubscribeFromAllTypes()

		expect(usingConvenienceMethods).not.toThrow()

	it "is chainable.", ()->

		expect(bus.publish "foo").toEqual bus
		expect(bus.subscribe "foo", ()->).toEqual bus
		expect(bus.unsubscribe "foo", ()->).toEqual bus
