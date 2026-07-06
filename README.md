This experiment is largely based on this video - https://www.youtube.com/watch?v=-a07Ief51H4&t=2714s

# Objectives

- validate replication
- use sentinel to change master dynamically
- work with multiple sentinels, to simulate use in different machines
  - start in the same network
  - explore the possibility of testing in different machines (with VM or docker containers)
- allow for automatic failover (even though i am only simulating for two machines)

To see the role (master, slave) of each redis instance

```sh
docker-compose exec -it redis-machine-a-master
redis-cli
INFO replication
```

To add a key-value pair to redis

```sh
SET test test
```

To confirm that sentinels are connected between each other

```sh
sentinel sentinels mymaster
sentinel masters
info sentinel
```

We need 3 sentinels (machines) to have an automatic failover. To manually update the new leader.

First elect a leader

```sh
docker exec -it <slave-container> redis-cli -p 6379 REPLICAOF NO ONE
```

Then inform the sentinel of the actual master

```sh
docker exec -it redis-machine-a-sentinel redis-cli -p 26379 SENTINEL REMOVE mymaster
docker exec -it redis-machine-a-sentinel redis-cli -p 26379 SENTINEL MONITOR mymaster <new-master-ip> 6379 1
```

# Run Local-Version

To run this experiment we first need to create a docker network

```sh
docker network create redis-test-net
```

The "local-version" is the one where we run both compose files individually.

```sh
docker compose up --build
```

Experiments with putting down master and sentinel to check the agreement and who the new master is, was made sucessfully. Replication and high availability (as is possible with one two machines) are confirmed.

# Run DockerFile

To run the experiment we need to create a subneted docker network

```sh
docker network create --subnet=172.28.0.0/16 redis-sim-outer
```

The dockerfile version is the next step two simulate two machines.

Run machine one (execute inside container-version/machine-a dir)

```sh
docker build -t redis-vm-one .
docker run --privileged --name redis-vm-one --network redis-sim-outer --ip 172.28.0.10 -p 6379:6379 -p 6380:6380 -p 26379:26379 redis-vm-one
```

```sh
docker build -t redis-vm-two .
docker run --privileged --name redis-vm-two --network redis-sim-outer --ip 172.28.0.20 -p 6381:6379 -p 6382:6379 -p 26380:26379 -p 26381:26379 redis-vm-two
```

Confirm conneciton exists between the two machines

```sh
docker exec -it redis-vm-one ping -c 2 172.28.0.20
```

Experiment with stoping the leader and restarting it to see how the system reacts.

```sh
docker pause redis-machine-a-one

docker compose start redis-machine-a-sentinel
docker compose up -d redis-machine-a-sentinel
```
