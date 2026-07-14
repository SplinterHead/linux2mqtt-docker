#!/bin/sh

# Base command
CMD="linux2mqtt"

# MQTT Broker Settings
if [ -n "$MQTT_HOST" ]; then
    CMD="$CMD --host $MQTT_HOST"
fi

if [ -n "$MQTT_PORT" ]; then
    CMD="$CMD --port $MQTT_PORT"
fi

if [ -n "$MQTT_USER" ]; then
    CMD="$CMD --username $MQTT_USER"
fi

if [ -n "$MQTT_PASSWORD" ]; then
    CMD="$CMD --password $MQTT_PASSWORD"
fi

if [ -n "$MQTT_CLIENT_ID" ]; then
    CMD="$CMD --client $MQTT_CLIENT_ID"
fi

if [ -n "$MQTT_QOS" ]; then
    CMD="$CMD --qos $MQTT_QOS"
fi

if [ -n "$MQTT_TIMEOUT" ]; then
    CMD="$CMD --timeout $MQTT_TIMEOUT"
fi

# General Settings
if [ -n "$NAME" ]; then
    CMD="$CMD --name $NAME"
fi

if [ -n "$INTERVAL" ]; then
    CMD="$CMD --interval $INTERVAL"
fi

if [ -n "$HA_PREFIX" ]; then
    CMD="$CMD --homeassistant-prefix $HA_PREFIX"
fi

if [ "$HA_DISABLE_ATTRIBUTES" = "true" ] || [ "$HA_DISABLE_ATTRIBUTES" = "1" ]; then
    CMD="$CMD --homeassistant-disable-attributes"
fi

if [ -n "$TOPIC_PREFIX" ]; then
    CMD="$CMD --topic-prefix $TOPIC_PREFIX"
fi

if [ -n "$LOGDIR" ]; then
    CMD="$CMD --logdir $LOGDIR"
fi

if [ -n "$VERBOSE" ]; then
    # Expecting values like 'v', 'vv', 'vvvvv'
    CMD="$CMD -$VERBOSE"
fi

# Metrics Flags
if [ -n "$ENABLE_CPU" ]; then
    CMD="$CMD --cpu=$ENABLE_CPU"
fi

if [ "$ENABLE_VM" = "true" ] || [ "$ENABLE_VM" = "1" ]; then
    CMD="$CMD --vm"
fi

if [ "$ENABLE_FANS" = "true" ] || [ "$ENABLE_FANS" = "1" ]; then
    CMD="$CMD --fan"
fi

if [ "$ENABLE_TEMP" = "true" ] || [ "$ENABLE_TEMP" = "1" ]; then
    CMD="$CMD --temp"
fi

if [ -n "$ENABLE_CONNECTIONS" ]; then
    CMD="$CMD --connections $ENABLE_CONNECTIONS"
fi

if [ -n "$ENABLE_PACKAGES" ]; then
    CMD="$CMD --packages $ENABLE_PACKAGES"
fi

if [ -n "$ENABLE_DISCOVERY" ]; then
    OLD_IFS="$IFS"
    IFS=','
    for platform in $ENABLE_DISCOVERY; do
        CMD="$CMD --discovery=$platform"
    done
    IFS="$OLD_IFS"
fi

if [ -n "$ENABLE_DU" ]; then
    # Support multiple disks separated by commas, e.g. ENABLE_DU="/,/var/spool"
    # We temporarily set the Internal Field Separator to comma to loop through them
    OLD_IFS="$IFS"
    IFS=','
    for disk in $ENABLE_DU; do
        CMD="$CMD --du=$disk"
    done
    IFS="$OLD_IFS"
fi

if [ -n "$ENABLE_NET" ]; then
    # Support multiple network interfaces separated by commas, e.g. ENABLE_NET="eth0,60,wlan0,60"
    # Note: linux2mqtt takes --net=interface,interval. 
    # To pass multiple, users can space-separate them in the env var: ENABLE_NET="eth0,60 wlan0,60"
    # Or we can split by space.
    for net in $ENABLE_NET; do
        CMD="$CMD --net=$net"
    done
fi

echo "Starting linux2mqtt with command:"
echo "$CMD"

# Execute the final command
exec $CMD
