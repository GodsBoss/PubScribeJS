pubsub = require "../src/pubscribe"

EventBus = pubsub.EventBus

describe "Event bus", ()->

	it "is easily constructed.", ()->

		bus = new EventBus

	it "lets clients publish events.", ()->

		bus = new EventBus
		bus.publish "foo", ()->
