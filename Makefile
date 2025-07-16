PROJECT = rabbitmq_mqtt_retained_msg_khepri
PROJECT_DESCRIPTION = RabbitMQ MQTT Retained message store based on khepri
PROJECT_MOD = rabbitmq_mqtt_retained_msg_khepri
PROJECT_VERSION = v4.1.1

# We do not need QUIC as dependency of emqtt.
BUILD_WITHOUT_QUIC=1
export BUILD_WITHOUT_QUIC

DEPS = rabbit_common rabbit amqp_client rabbitmq_mqtt
TEST_DEPS = rabbitmq_ct_helpers rabbitmq_ct_client_helpers

DEP_EARLY_PLUGINS = rabbit_common/mk/rabbitmq-early-plugin.mk
DEP_PLUGINS = rabbit_common/mk/rabbitmq-plugin.mk



# FIXME: Use erlang.mk patched for RabbitMQ, while waiting for PRs to be
# reviewed and merged.

ERLANG_MK_REPO = https://github.com/rabbitmq/erlang.mk.git
ERLANG_MK_COMMIT = rabbitmq-tmp

include ../../rabbitmq-components.mk
include ../../erlang.mk