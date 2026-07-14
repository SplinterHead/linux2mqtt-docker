# Linux2MQTT Docker Image

This directory contains the necessary instructions to build a lightweight, containerized version of the `linux2mqtt` system metric reporting utility. This image wraps the Python `linux2mqtt` package and provides a robust, environment-variable-driven entrypoint designed perfectly for automated deployments in an orchestration cluster.

By running this image dynamically across your cluster nodes (for example, as a global service), you can passively collect performance and hardware metrics from every node and ship them to an MQTT broker like Mosquitto for ingestion into Home Assistant.

---

## ✨ Features

- **Ultra-Lightweight**: Built on Alpine Linux and heavily optimized by leveraging native pre-compiled packages, bypassing heavy Python build compilers, and keeping the final image footprint incredibly small.
- **Multi-Architecture**: Native support for `linux/amd64`, `linux/arm64`, `linux/arm/v7`, and `linux/arm/v6` out of the box, making it perfect for Raspberry Pi fleets.
- **Fully Configurable**: Every single `linux2mqtt` argument and flag is seamlessly exposed via environment variables for easy drop-in use in Kubernetes, Docker Swarm, or Docker Compose.

---

## 🛠️ Configuration & Environment Variables

Unlike the raw python package which relies heavily on command-line arguments, this Docker image abstracts the arguments into clean environment variables. These can easily be passed via a `.env` file or directly in your `compose.yml` orchestration files.

### 🌐 MQTT Broker Configuration

These variables dictate how the container connects to your MQTT broker.

| Variable         | Description                                                                                                          | Required | Example                        |
| ---------------- | -------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------ |
| `MQTT_HOST`      | The hostname or IP of the MQTT broker. If your broker is on the same cluster network, you can use the service alias. | **Yes**  | `mosquitto` or `192.168.86.10` |
| `MQTT_PORT`      | The port the MQTT broker is listening on.                                                                            | No       | `1883` (Default)               |
| `MQTT_USER`      | Username for MQTT authentication.                                                                                    | No       | `ha_metrics_user`              |
| `MQTT_PASSWORD`  | Password for MQTT authentication.                                                                                    | No       | `super_secure_pass`            |
| `MQTT_CLIENT_ID` | Custom Client ID for the MQTT connection.                                                                            | No       | `my_custom_client`             |
| `MQTT_QOS`       | Quality of Service level for standard MQTT messages (0, 1, or 2).                                                    | No       | `1`                            |
| `MQTT_TIMEOUT`   | Connection timeout in seconds.                                                                                       | No       | `60`                           |

### ⚙️ General Settings

| Variable                | Description                                                                                                                                                                                                                                        | Required | Example                   |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------- |
| `NAME`                  | The friendly name for this sensor inside Home Assistant and the MQTT topic prefix. If deploying globally across a cluster, it is highly recommended to dynamically pass the node's hostname to this variable so you can differentiate the metrics. | No       | `srv-node-01`             |
| `INTERVAL`              | The baseline interval (in seconds) that `linux2mqtt` will publish standard metrics.                                                                                                                                                                | No       | `30`                      |
| `HA_PREFIX`             | MQTT discovery topic prefix for Home Assistant.                                                                                                                                                                                                    | No       | `homeassistant` (Default) |
| `HA_DISABLE_ATTRIBUTES` | Disable Home Assistant attributes and expose everything as separate entities.                                                                                                                                                                      | No       | `true` or `1`             |
| `TOPIC_PREFIX`          | Prefix for the standard MQTT topics.                                                                                                                                                                                                               | No       | `linux` (Default)         |
| `LOGDIR`                | Enable logging to a specified directory.                                                                                                                                                                                                           | No       | `/var/log/linux2mqtt`     |
| `VERBOSE`               | Sets the logging debug level in the container's standard output. Supply one or more `v` characters to increase verbosity.                                                                                                                          | No       | `vvvvv`                   |

### 📊 Metric Flags

These environment variables act as toggles and configuration flags for the specific hardware/system metrics you wish to collect and publish.

| Variable             | Description                                                                                                                                            | Example                          |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------- |
| `ENABLE_CPU`         | Enables CPU utilisation tracking. Set the value to the collection interval (in seconds) over which the average CPU is measured before being published. | `60` (Measures average over 60s) |
| `ENABLE_VM`          | Enables Virtual Memory (RAM) tracking. Accepts boolean strings.                                                                                        | `true` or `1`                    |
| `ENABLE_FANS`        | Enables fan speed tracking (useful for bare-metal nodes).                                                                                              | `true` or `1`                    |
| `ENABLE_TEMP`        | Enables temperature monitoring for thermal zones. Accepts boolean strings.                                                                             | `true` or `1`                    |
| `ENABLE_CONNECTIONS` | Enables active IP/Port network connection monitoring. Set the value to the polling interval (in seconds).                                              | `10`                             |
| `ENABLE_PACKAGES`    | Enables checking for package updates. Set the value to the polling interval in seconds.                                                                | `3600`                           |
| `ENABLE_DISCOVERY`   | Enables MQTT discovery for specific platforms. Supply multiple comma-separated platforms.                                                              | `homeassistant`                  |
| `ENABLE_DU`          | Monitors disk usage percentages and free space. You can supply multiple comma-separated volume mount paths to monitor multiple disks on the host.      | `/,/var/spool`                   |
| `ENABLE_NET`         | Monitors network interface throughput. Supply space-separated strings containing the `interface,interval`.                                             | `eth0,60 wlan0,60`               |

---

## 🚀 Example Docker Compose Deployment

To monitor your host machine, you can deploy this image as a standard service within your `docker-compose.yml` file.

> **Note on Volumes:** To allow the container to accurately measure the host's disk space, network interfaces, and CPU, you usually need to mount the host's root filesystem (or specific directories) into the container in a read-only state.

```yaml
services:
  linux2mqtt:
    image: ghcr.io/SplinterHead/linux2mqtt:latest
    container_name: linux2mqtt
    networks:
      - proxy
    environment:
      # Hardcode your host's name or pass it via the .env file
      NAME: my-server
      MQTT_HOST: mosquitto
      MQTT_PORT: 1883
      ENABLE_CPU: 60
      ENABLE_VM: true
      ENABLE_DU: /hostfs
      VERBOSE: vv
    volumes:
      # Mount the host filesystem so the container can read disk usage accurately
      - /:/hostfs:ro
    restart: unless-stopped
```
