# mc-server-podman-fast-setup

Fast rootless Podman setup for a Minecraft Java server on Debian 13. Uses [`itzg/minecraft-server`](https://github.com/itzg/docker-minecraft-server), a persistent Podman volume, and no public RCON port.

## Install

Run as a normal user with `sudo` access. Running the script accepts the [Minecraft EULA](https://www.minecraft.net/eula).

```bash
git clone https://github.com/establishmyass/mc-server-podman-fast-setup.git && cd mc-server-podman-fast-setup && ./setup.sh
```

Open incoming TCP port `25565` in the VPS firewall, then connect to `SERVER_IP:25565`.

## Options

Safe defaults use Mojang/Microsoft authentication. Override values before the command:

```bash
MEMORY=4G MAX_PLAYERS=20 VIEW_DISTANCE=10 SIMULATION_DISTANCE=8 ./setup.sh
```

For PrismLauncher offline/local accounts:

```bash
ONLINE_MODE=FALSE ./setup.sh
```

Offline mode allows username and OP impersonation. Do not expose an offline-mode OP account on an untrusted public server.

Use Paper instead of Vanilla:

```bash
TYPE=PAPER ./setup.sh
```

Available variables: `NAME`, `VOLUME`, `PORT`, `MEMORY`, `TYPE`, `ONLINE_MODE`, `VIEW_DISTANCE`, `SIMULATION_DISTANCE`, `MAX_PLAYERS`, `IMAGE`.

## Manage

```bash
podman --cgroup-manager=cgroupfs logs -f minecraft
```

```bash
podman --cgroup-manager=cgroupfs restart minecraft
```

```bash
podman --cgroup-manager=cgroupfs exec minecraft rcon-cli list
```

```bash
podman --cgroup-manager=cgroupfs exec minecraft rcon-cli "op PLAYER_NAME"
```

## Backup

```bash
podman --cgroup-manager=cgroupfs stop minecraft && podman --cgroup-manager=cgroupfs volume export minecraft-data | gzip > "minecraft-backup-$(date +%F-%H%M).tar.gz" && podman --cgroup-manager=cgroupfs start minecraft
```

## DNS

Point an `A` record such as `mc.example.com` to the VPS IP. Use DNS-only mode; Caddy is unnecessary for Minecraft TCP on port 25565.

## License

GPL-3.0. The container image and Minecraft server are distributed under their own terms.
