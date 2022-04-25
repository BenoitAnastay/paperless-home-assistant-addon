#!/usr/bin/env bash

# https://github.com/Hronom/wait-for-redis

redis-server --daemonize yes

echo "Start waiting for Redis fully start. Host '$HOST', '$PORT'..."
echo "Try ping Redis... "
PONG=`redis-cli ping | grep PONG`
while [ -z "$PONG" ]; do
    sleep 1
    echo "Retry Redis ping... "
    PONG=`redis-cli ping | grep PONG`
done
echo "Redis fully started."