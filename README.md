This experiment is largely based on this video - https://www.youtube.com/watch?v=-a07Ief51H4&t=2714s

# Objectives

- validate replication
- use sentinel to change master dynamically
- work with multiple sentinels, to simulate use in different machines
  - start in the same network
  - explore the possibility of testing in different machines (with VM or docker containers)
- allow for automatic failover (even though i am only simulating for two machines)

To run this experimento we first need to create a docker network

```sh
docker network create redis-test-net
```

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
