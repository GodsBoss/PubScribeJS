PubScribeJS
===========

Publish/Subscribe in CoffeeScript and therefore JavaScript. License is GPLv3.
See LICENSE for info.

Usage
-----

### Simple usage

Include the module:

    var pubsub = require('path/to/pubscribe.js');

Creates a new event bus:

		var bus = pubsub.create();

Subscribes callback to `"foo"` events. If `"foo"` events take place, the
callback will be notified:

    bus.subscribe("foo", callback);

Publishes an event on the bus of type `"foo"`. All subscribers to `"foo"` are
notified. They are called with three arguments: `true`, `3` and an object with
the lone property `x` with the value `5` (and all properties inherited from
`Object.prototype`):

    bus.publish("foo", true, 3, {x:5});

Removes the callback from the list of subscribers for `"foo"`. It will no
longer be called when a `"foo"` event takes place:

    bus.unsubscribe("foo", callback);

### Restrict to certain event types

    var bus = pubsub.create("foo", "bar");

If created this way, the bus will only accept the event types `"foo"` and
`"bar"` and throws an error on any other event types (e.g. `"baz"`). This
applies to subscribing, unsubscribing and publishing. For valid events,
everything works as expected.

### Use additional methods directly

If the event bus is restricted to certain event types, additional methods will
be created which can be used instead of the generic ones.

    var bus = pubsub.create("clicked button");

    bus.subscribeToClickedButton(callback);
		bus.unsubscribeFromClickedButton(callback);
		bus.publishClickedButton();

Event type name parts can be separated by spaces, hyphens or underscores.

Beware! If two event type names will be converted to the same method name, one
will overwrite the other. Example:

    var bus = pubsub.create("foo bar", "foo_bar");

Although these are two distinct event types, there are only methods for one of
them.
