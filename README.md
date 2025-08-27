# rabbitmq-mqtt-retained-msg-store-khepri

As mentioned in the [RabbiMQ MQTT Plugin documentation](https://www.rabbitmq.com/docs/mqtt#retained), there is a significant limitation when handling retained messages in a multi-node RabbitMQ cluster: both available retain store implementations (ETS and DETS) are node-local.

This plugin aims to address that limitation for clusters with small to moderate loads by using Khepri as a storage backend for retained messages, thereby making them available cluster-wide.

**Note:** This is still highly experimental. Use at your own risk


## Usage

Builds are available of every release of the plugin.


See [Plugin Installation](https://www.rabbitmq.com/docs/installing-plugins) for details about how to install plugins that do not ship with RabbitMQ.

Then, to configure the store, use the `mqtt.retained_message_store`configuration key:
```
## use Khepri store for retained messages
mqtt.retained_message_store = rabbit_mqtt_retained_msg_store_khepri
```

## Building from source

### Dependencies

This plugin only relies on RabbitMQ. All [RabbitMQ required libraries and tools](https://www.rabbitmq.com/docs/build-server#prerequisites) must be properly installed.

### Building

```bash

# Clone RabbitMQ server repository
git clone --depth 1 --branch  v4.1.2 https://github.com/rabbitmq/rabbitmq-server.git

# Clone plugin into deps directory
git clone git@github.com:NicolasFloquet/rabbitmq-mqtt-retained-msg-khepri.git rabbitmq-server/deps/rabbitmq_mqtt_retained_msg_khepri

cd ./rabbitmq-server
make -C deps/rabbitmq_mqtt_retained_msg_khepri
make -C deps/rabbitmq_mqtt_retained_msg_khepri DIST_AS_EZS=yes dist

```

### Known limitations

* As for other store implementations, topic filters with wildcards are **not** supported.
* For now this plugin doesn't manage message expiration.
* Overall performance is yet to be evaluated, but please expect it to be way lower than other stores.