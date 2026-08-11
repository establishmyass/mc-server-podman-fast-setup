#!/usr/bin/env bash
set -euo pipefail

NAME=${NAME:-minecraft}
VOLUME=${VOLUME:-minecraft-data}
PORT=${PORT:-25565}
MEMORY=${MEMORY:-2G}
TYPE=${TYPE:-VANILLA}
ONLINE_MODE=${ONLINE_MODE:-TRUE}
VIEW_DISTANCE=${VIEW_DISTANCE:-8}
SIMULATION_DISTANCE=${SIMULATION_DISTANCE:-6}
MAX_PLAYERS=${MAX_PLAYERS:-10}
IMAGE=${IMAGE:-docker.io/itzg/minecraft-server:latest}

command -v apt-get >/dev/null || { echo "Ubuntu 24.04-26.04 with apt-get required" >&2; exit 1; }
sudo apt-get update
sudo apt-get install -y podman uidmap slirp4netns fuse-overlayfs

podman_cmd=(podman --cgroup-manager=cgroupfs)
"${podman_cmd[@]}" volume inspect "$VOLUME" >/dev/null 2>&1 || "${podman_cmd[@]}" volume create "$VOLUME"
"${podman_cmd[@]}" rm -f "$NAME" >/dev/null 2>&1 || true
"${podman_cmd[@]}" run -d --name="$NAME" --pull=always --restart=unless-stopped --stop-timeout=60 --network=slirp4netns:port_handler=slirp4netns -p="${PORT}:25565/tcp" --env=EULA=TRUE --env="MEMORY=$MEMORY" --env="TYPE=$TYPE" --env="ONLINE_MODE=$ONLINE_MODE" --env="VIEW_DISTANCE=$VIEW_DISTANCE" --env="SIMULATION_DISTANCE=$SIMULATION_DISTANCE" --env="MAX_PLAYERS=$MAX_PLAYERS" --volume="$VOLUME:/data" "$IMAGE"

for _ in $(seq 1 90); do
  if "${podman_cmd[@]}" logs "$NAME" 2>&1 | grep -q 'Done (.*)! For help'; then
    "${podman_cmd[@]}" ps --filter "name=$NAME"
    echo "Ready: connect to SERVER_IP:$PORT"
    exit 0
  fi
  if [ "$("${podman_cmd[@]}" inspect -f '{{.State.Status}}' "$NAME")" != running ]; then
    break
  fi
  sleep 2
done

"${podman_cmd[@]}" logs --tail=200 "$NAME" >&2
echo "Server did not become ready" >&2
exit 1
