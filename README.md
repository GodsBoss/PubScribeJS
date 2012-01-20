PubScribeJS
===========

Publish/Subscribe in CoffeeScript and therefore JavaScript. License is GPLv3.
See LICENSE for info.

Usage
-----

*** Simple usage ***

    var pubsub = require('path/to/pubscribe.js');

Include the module.

		var bus = pubsub.create();

Creates a new event bus.

    bus.subscribe("foo", callback);

Subscribes callback to `"foo"` events. If `"foo"` events take place, the
callback will be notified.

    bus.publish("foo", true, 3, {x:5});

Publishes an event on the bus of type `"foo"`. All subscribers to `"foo"` are
notified. They are called with three arguments: `true`, `3` and an object with
the lone property `x` with the value `5` (and all properties inherited from
`Object.prototype`).

    bus.unsubscribe("foo", callback);

Removes the callback from the list of subscribers for `"foo"`. It will no
longer be called when a `"foo"` event takes place.

*** Restrict to certain event types ***

    var bus = pubsub.create("foo", "bar");

If created this way, the bus will only accept the event types `"foo"` and
`"bar"` and throws an error on any other event types (e.g. `"baz"`). This
applies to subscribing, unsubscribing and publishing. For valid events,
everything works as expected.
