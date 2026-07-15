FROM alpine:3.24

# Install python3 and pip, along with pre-compiled package for psutil
# We use --break-system-packages and --no-deps so pip only installs linux2mqtt/paho-mqtt and not psutil (which we just installed via apk).
RUN apk add --no-cache python3 py3-pip py3-psutil && \
    pip install --no-cache-dir --break-system-packages --no-deps linux2mqtt paho-mqtt && \
    apk del py3-pip

# Copy and set up the entrypoint script in a single layer
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Run the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
