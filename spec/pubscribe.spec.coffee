pubscribe = require "../src/pubscribe"

class Callback
	constructor:()->
		@callArgumentsStack = []

	call:(args...)=>
		@callArgumentsStack.push args

	numberOfCalls:()->
		@callArgumentsStack.length

	wasCalled:()->
		@numberOfCalls() > 0

describe "Simple Event bus", ()->

	bus = null

	beforeEach ()->
		bus = pubscribe.create()

	it "is easily constructed.", ()->

	it "lets clients publish events.", ()->

		bus.publish "foo", ()->

	it "lets client subscribe to events.", ()->

		bus.subscribe "foo", ()->

	it "notifies a client of events they subscribed to.", ()->

		callback = new Callback

		bus.subscribe "foo", callback.call
		bus.publish "foo"

		expect(callback.wasCalled()).toBeTruthy()

	it "notifies all clients of events they subscribed to.", ()->

		aCallback = new Callback
		anotherCallback = new Callback

		bus.subscribe "foo", aCallback.call
		bus.subscribe "foo", anotherCallback.call

		bus.publish "foo"

		expect(aCallback.wasCalled() and anotherCallback.wasCalled()).toBeTruthy()

	it "does not notify clients about events they did not subscribe to.", ()->

		fooSubscriber = new Callback
		barSubscriber = new Callback

		bus.subscribe "foo", fooSubscriber.call
		bus.subscribe "bar", barSubscriber.call
		bus.publish "foo"

		expect(fooSubscriber.wasCalled()).toBeTruthy()
		expect(barSubscriber.wasCalled()).toBeFalsy()

	it "passes arguments to subscribers.", ()->

		publishedArgs = [8, "bar", true]
		subscriber = new Callback

		bus.subscribe "foo", subscriber.call
		bus.publish.apply null, ["foo"].concat publishedArgs

		expect(subscriber.callArgumentsStack[0]).toEqual publishedArgs

	it "prevents multi-subscribers from being called multiple times.", ()->

		subscriber = new Callback

		bus.subscribe "bar", subscriber.call
		bus.subscribe "bar", subscriber.call
		bus.publish "bar"

		expect(subscriber.numberOfCalls()).toEqual 1

	it "lets subscribers unsubscribe from events.", ()->

		subscriber = new Callback

		bus.subscribe "baz", subscriber.call
		bus.unsubscribe "baz", subscriber.call
		bus.publish "baz"

		expect(subscriber.wasCalled()).toBeFalsy()

	it "ignores exceptions thrown by subscribers.", ()->

		subscriber = new Callback

		throwingSubscriber = ()->
			throw new Error("I am an error!")

		bus.subscribe "bar", throwingSubscriber
		bus.subscribe "bar", subscriber.call

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
		bus = pubscribe.create "foo"

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

		aSubscriber = new Callback
		anotherSubscriber = new Callback

		bus.subscribe "foo", aSubscriber.call
		bus.subscribe "foo", anotherSubscriber.call
		bus.publish "foo"

		expect(aSubscriber.wasCalled() and anotherSubscriber.wasCalled()).toBeTruthy()

	it "publishes no events to subscribers which unsubscribed.", ()->

		callback = new Callback

		bus.subscribe "foo", callback.call
		bus.unsubscribe "foo", callback.call
		bus.publish "foo"

		expect(callback.wasCalled()).toBeFalsy()

	it "Creates additional convenience methods.", ()->

		subscriber = new Callback
		unsubscriber = new Callback

		bus.subscribeToFoo subscriber.call
		bus.subscribeToFoo unsubscriber.call
		bus.unsubscribeFromFoo unsubscriber.call
		bus.publishFoo 4, true, "yes"

		expect(subscriber.callArgumentsStack[0]).toEqual [4, true, "yes"]
		expect(unsubscriber.wasCalled()).toBeFalsy()

	it "'s convenience methods are camelized versions of the event types.", ()->

		types = ["type with spaces", "use_underscores", "with-hyphens"]

		bus = pubscribe.create.apply pubscribe, types

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
