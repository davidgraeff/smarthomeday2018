# MQTT Broker Bridge Things and MQTT Things arrive in ESH

If you haven't heared about MQTT yet, it is probably time to have a [look](https://en.wikipedia.org/wiki/MQTT). Quoting Wikipedia here:

> "MQTT (Message Queuing Telemetry Transport) is an ISO standard (ISO/IEC PRF 20922)[2] publish-subscribe-based messaging protocol. It works on top of the TCP/IP protocol. It is designed for connections with remote locations where a "small code footprint" is required or the network bandwidth is limited."

The Publish/Subscribe pattern is event-driven and enables messages to be pushed to clients.
The central communication point is the MQTT broker, it is in charge of dispatching all messages between the senders and the rightful receivers.
A client that publishes a message to the broker, includes a topic into the message.
The topic is used as the routing information for the broker.
Each client that wants to receive messages subscribes to one or more topics and the broker delivers all messages with the matching topic to the client.

A topic is a simple string that can have more hierarchy levels, which are separated by a slash.
A sample topic for sending temperature data of the living room could be **house/living-room/temperature**.

In recent years MQTT got a lot of attention for IoT and home automation purposes.
Propably mainly because of the simplicity of the protocol and its many client and server implementations, desktop and embedded, for several programming languages.
A more recent features is MQTT via Websockets. That way MQTT is now even accessible for web applications.

## MQTT architecture: Three new extensions

In this section a rough idea of the overall architecture is given and how those new extensions interact with another and the Eclipse Smarthome framework.

The new MQTT architecture has been realized by 3 independant extensions plus
an overhaul of the existing `io.transport.mqtt` package.
It took about one year to finish this support, from the first line to about 7000 lines of fully test covered
code that lives up to the high coding standards of the Eclipse Smarthome (ESH) platform.

The API was redesigned to be fully asynchronous, because the switch to Java 8 made it possible
to elaborate on the `CompletableFuture<?>` class.

### MQTT core services
Have a look at the following diagram:

![MQTT service](6c00d2ad5e4bc553f5f209118307d8fd/raw/esh_mqtt-CoreArchitecture.png "MQTT service")

The core package "`io.transport.mqtt`" contains the `MqttService` service.
That service is essentially an observable list of `MQTTBrokerConnection`s.
By building on the OSGI service factory pattern,
the user is able to configure multiple of those connections via any means to apply configuration to the **OSGi Configuration Admin** service to instantiate `MqttBrokerConnectionService` instances. An instance creates a `MQTTBrokerConnection` and inserts it into the `MqttService`.

Below the core, you will find the "Embedded MQTT broker" extension. Its purpose is to start an embedded MQTT broker and create a `MQTTBrokerConnection` to it. That connection also registers to the `MqttService`.

### MQTT Broker configuration and MQTT Things

So far, there is no visible difference to the user. He is not able to interact with any MQTT client yet.
Have a look at the next diagram. Two more extensions introduce ESH Things that interact with MQTT topics
and allow to configure Brokers, modelled as ESH Bridges.

![MQTT architecture](6c00d2ad5e4bc553f5f209118307d8fd/raw/esh_mqtt-ExtensionsArchitecture.png "MQTT architecture")

The "MQTT Broker configuration" extension introduces two `Bridge` types, each representing a MQTT broker connection.
They differ in that the first `Bridge` type is managing a *.thing* file or Paper UI user configured Broker,
while the second type represents a "system" Broker connection found via the `MqttService` service list.

In the bottom part of the diagram you will notice the "MQTT Things" Extension.
It consists of multiple Thing handlers to live up to different MQTT conventions
as well as a generic MQTT Thing handler.
Find more details about this extension further down in the text.

### Modularity

Before you will learn about all the new features introduced with those new extensions,
first a word about the modularity of this architecture:
You will notice that the **Embedded broker io extension** is fully independent.
The **MQTT Things extension** requires access to a `MQTTBrokerConnection` object to actually communicate with a MQTT broker.
To retrieve the desired connection object, a MQTT Thing handler expects a Bridge with an `AbstractBrokerHandler` derived handler class.
Therefore it is coupled to the **MQTT Broker configuration** extension.
At the moment there is no need to offer alternatives and make those two extensions loosly coupled.
But if desired, the abstract class could be replaced by an `Interface` in the future.

## "MQTT Broker configuration" extension

An essential part of good MQTT support is the MQTT broker configuration,
which is finally possible in a graphical fashion:

[picture of paperui: manually define a MQTT broker connection]
[picture of paperui: inbox, showing a found MQTT broker]

The nifty reader might have noticed. Yes, this extension supports MQTT broker
auto discovery. The MQTT specification unfortunately does not require brokers
to announce themselves in a standard way, so this feature is based on heuristic port scans.

To wrap it up: MQTT can be enabled by
(1) installing, (2) configuring and (3) setting up a broker server next to your Eclipse Smarthome software
and (4) clicking on the found item in their Paper UI inbox. Right?

### Embedded MQTT broker 

Actually, it is even simpler, now that ESH comes with an embedded MQTT broker.
The broker can be pre-configured via a service configuration file as usually, or within Paper UI:

![Configure embedded MQTT Broker](6c00d2ad5e4bc553f5f209118307d8fd/raw/esh_embedded_configure.png "Configure embedded MQTT Broker")

### Broker connection status

Internally the extension knows what is going on and why a broker connection fails.
May it be wrong credentials, a denied tcp connection (i.e. firewall) or a maximum connection limit.

The former MQTT implementation knew about the reason as well. But instead of only
logging it, the reason is now directly presented to users via the Thing status:

[picture of paperui broker connection thing offline status]

This also means, the status is available for the automation rule engine to e.g.
react on a failing broker connection.

### System broker connections for ESH distributions and platform implementations

It is crucial to be able to pre-configure the Eclipse Smarthome platform to offer a seamless integration
of pre-installed extensions and other 3rd-party software like a MQTT broker.

Service configuration files can be used to define mentioned "system broker connections".

Instead of populating a "mqtt.conf" file, a distributor is now creating a "etc/*.cfg"
file that contains lines like the following:

```
service.pid="org.eclipse.smarthome.mqttbroker"
name="A mosquitto local installation"
username="username"
password="password"
clientID="localESH"
host="127.0.0.1"
secure=true
```

This is the equivalence of using Paper UI for configuring the service:

![Manage system broker connections](6c00d2ad5e4bc553f5f209118307d8fd/raw/esh_system_connection_manage.png "Manage system broker connections")

![Add system broker connection](6c00d2ad5e4bc553f5f209118307d8fd/raw/esh_system_connection_add.png "Add system broker connection")

ESH will not per-default mess with user defined Things by creating a MQTT Broker Thing on its own.
Instead system broker connections are available as `Discovery Results`,
internally and via the Paper UI Inbox like with auto-discovered external brokers.

## "MQTT Things" extension

The MQTT standard does not enforce any topic layout or topic value format. 
A smart light vendor can decide to publish his lights under a "vendorname/deviceID/light" MQTT topic
or use a totally different layout like "light/vendorname/deviceid".

People even disagree about the value format, sometimes it is "ON", sometimes "1" or "true".
Did you know that for Filipinos a switched-on light is "OPEN"?
And it doesn't even need to be English.

#### Auto discovery

And that is why MQTT topic and format conventions got established amongst the IoT community. 
The new **MQTT Things extension** supports two conventions out-of-the-box:

* The Homie 3.x specification: This MQTT convention defines the layout of MQTT topics and the value format is discribed via "attribute topics". No specific devices like "lights" or "switches" are defined though.
* The HomeAssistant MQTT Components specification: The related documents describe common components like a Light, a Switch, a Fan, an Air-Conditioner and so on. Anything that does not fit into any of those categories, can not be described with this convention.

Because the topic structure is known, the MQTT Things extension is able to provide auto-discovery and mapping of MQTT topics to ESH Things and Channels.

[picture of paperui inbox]

If more vendors could be convinced to stick to a fully thought throug MQTT convention, like
the *Homie 3.x* convention, those devices could be supported by ESH right away.

Vendor specific MQTT protocols can easily be added to the new MQTT infrastructure alternatively,
building on top of the provided embedded broker and broker connection configuration.

#### Generic MQTT Thing

It cannot be stressed enough, to consider changing existing MQTT
client devices to a MQTT convention like the mentioned *Homie 3.x* convention.
That might not be possible in some cases though. 

It is always possible to create a manual MQTT Thing by selecting the MQTT broker Bridge Thing and a Thing name:

[picture of paperui manual MQTT Thing creation]

By adding Channels to your Thing, you actually bind MQTT topics to your ESH world.
The following channel types are supported:

* String: This channel can show the received text on the given topic and can send text to a given topic.
* Number: This channel can show the received number on the given topic and can send a number to a given topic. It can have min, max and step values.
* Dimmer: This channel handles numeric values as percentages. It can have min, max and step values.
* Contact: This channel represents an open/close (on/off) state of a given topic.
* Switch: This channel represents an on/off state of a given topic and can send an on/off value to a given topic. This channel takes a configuration for the ON and OFF state, because some people use "1" and "0", some "true" and "false" and so on.
* Color: This channel handles color values in RGB and HSB format.

[picture of paperui example Switch channel config page]

Each channel supports a transformation pattern to extract a state from a structured response like JSON.
An example would be the pattern `JSONPATH:$.device.status.temperature` for an
incoming MQTT message of `{device: {status: { temperature: 23.2 }}}`.

### MQTT for own bindings/extensions

You are encouraged to a have a look at the `MQTTBrokerConnection` class and companion APIs in the `org.eclipse.smarthome.io.transport.mqtt` bundle to implement your next MQTT based binding.

The asynchronous API makes it easy to subscribe to many topics at once and do something when one specific or all
topics have received their retained values.

A helper class exists to populate class object fields, with each field representing a single MQTT topic in a more complex hierarchy.

## Conclusion

It is finally possible to easily start a MQTT broker,
setup broker connections graphically and monitor their status.
MQTT topics can be bound to ESH Channels via the REST API and the Paper UI.
Two implementation examples of MQTT topic auto discovery and mapping to ESH Things and Channels
are given in the MQTT Things extension.

This blog post should have given you an overview of what
the new MQTT architecture consists of and what it is capable of doing.
