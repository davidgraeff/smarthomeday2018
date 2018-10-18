echo "Publish Homie and HomeAssistant topics on local MQTT broker"
mosquitto_pub -q 1 -r -t "homeassistant/switch/node/testobject/config" -m "{'name':'testname','state_topic':'test/switch','command_topic':'test/switch/set'}"

mosquitto_pub -q 1 -r -t 'homie/mydevice/$name' -m 'My device'
mosquitto_pub -q 1 -r -t 'homie/mydevice/$state' -m 'ready'
mosquitto_pub -q 1 -r -t 'homie/mydevice/$nodes' -m 'testnode'
mosquitto_pub -q 1 -r -t 'homie/mydevice/testnode/$name' -m 'Test node'
mosquitto_pub -q 1 -r -t 'homie/mydevice/testnode/$type' -m 'Type'
mosquitto_pub -q 1 -r -t 'homie/mydevice/testnode/$properties' -m 'switchy'
mosquitto_pub -q 1 -r -t 'homie/mydevice/testnode/switchy/$name' -m 'My Switchy'
mosquitto_pub -q 1 -r -t 'homie/mydevice/testnode/switchy/$setable' -m 'true'
mosquitto_pub -q 1 -r -t 'homie/mydevice/testnode/switchy/$setable' -m 'true'
mosquitto_pub -q 1 -r -t 'homie/mydevice/testnode/switchy/$datatype' -m 'boolean'
mosquitto_pub -q 1 -r -t 'homie/mydevice/$homie' -m '3.0'  
mosquitto_pub -q 1 -r -t 'homie/mydevice/$stats/interval' -m '60' 