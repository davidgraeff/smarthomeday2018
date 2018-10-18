echo "Publish Homie and HomeAssistant topics on local MQTT broker"
alias pub="mosquitto_pub -q 1 -r -t"
pub "homeassistant/switch/node/testobject/config" -m "{'name':'testname','state_topic':'test/switch','command_topic':'test/switch/set'}"

pub 'homie/mydevice/$name' -m 'My device'
pub 'homie/mydevice/$state' -m 'ready'
pub 'homie/mydevice/$nodes' -m 'testnode'
pub 'homie/mydevice/testnode/$name' -m 'Test node'
pub 'homie/mydevice/testnode/$type' -m 'Type'
pub 'homie/mydevice/testnode/$properties' -m 'switchy'
pub 'homie/mydevice/testnode/switchy/$name' -m 'My Switchy'
pub 'homie/mydevice/testnode/switchy/$setable' -m 'true'
pub 'homie/mydevice/testnode/switchy/$setable' -m 'true'
pub 'homie/mydevice/testnode/switchy/$datatype' -m 'boolean'
pub 'homie/mydevice/$homie' -m '3.0'  
pub 'homie/mydevice/$stats/interval' -m '60' 

pub 'homie/seconddevice/$name' -m 'My second device'
pub 'homie/seconddevice/$state' -m 'ready'
pub 'homie/seconddevice/$nodes' -m 'testnode'
pub 'homie/seconddevice/testnode/$name' -m 'Test node'
pub 'homie/seconddevice/testnode/$type' -m 'Type'
pub 'homie/seconddevice/testnode/$properties' -m 'switchy'
pub 'homie/seconddevice/testnode/switchy/$name' -m 'My Switchy'
pub 'homie/seconddevice/testnode/switchy/$setable' -m 'true'
pub 'homie/seconddevice/testnode/switchy/$setable' -m 'true'
pub 'homie/seconddevice/testnode/switchy/$datatype' -m 'boolean'
pub 'homie/seconddevice/$homie' -m '3.0'  
pub 'homie/seconddevice/$stats/interval' -m '60' 
