# Default recipe
default:
    @just --list

# Build the docker container
build tag="linux2mqtt:latest":
    docker build -t {{tag}} .

# Run shellcheck on the entrypoint script
shellcheck:
    shellcheck -e SC2086 -e SC2153 entrypoint.sh
