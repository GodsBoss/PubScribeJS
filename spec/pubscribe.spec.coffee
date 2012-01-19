pubsub = require "../src/pubscribe"

EventBus = pubsub.EventBus

describe "Event bus", ()->

	it "is easily constructed.", ()->

		bus = new EventBus

	it "lets clients publish events.", ()->

		bus = new EventBus
		bus.publish "foo", ()->

	it "lets client subscribe to events.", ()->

		bus = new EventBus
		bus.subscribe "foo", ()->

	it "notifies a client of events they subscribed to.", ()->

		notified = false

		notify = ()->
			notified = true

		bus = new EventBus
		bus.subscribe "foo", notify
		bus.publish "foo"

		expect(notified).toBeTruthy()

	it "notifies all clients of events they subscribed to.", ()->

		notified = [false, false]

		notify1 = ()->
			notified[0] = true

		notify2 = ()->
			notified[1] = true

		bus = new EventBus

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

		bus = new EventBus

		bus.subscribe "foo", notify1
		bus.subscribe "bar", notify2
		bus.publish "foo"

		expect(notified).toEqual [true, false]

	it "passes arguments to subscribers.", ()->

		publishedArgs = [8, "bar", true]
		argsSubscribersAreCalledWith = undefined

		callback = (args...)->
			argsSubscribersAreCalledWith = args

		bus = new EventBus
		bus.subscribe "foo", callback
		bus.publish.apply null, ["foo"].concat publishedArgs

		expect(argsSubscribersAreCalledWith).toEqual publishedArgs

	it "prevents multi-subscribers from being called multiple times.", ()->

		calls = 0

		notify = ()->
			calls++

		bus = new EventBus
		bus.subscribe "bar", notify
		bus.subscribe "bar", notify
		bus.publish "bar"

		expect(calls).toEqual 1
