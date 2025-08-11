#!/usr/bin/env bash

# Test script for Erlang node clustering in Docker Swarm

echo "Testing Erlang node clustering..."

# Get the service name
SERVICE_NAME="kanban_web"

# Get all running containers for the service
CONTAINERS=$(docker service ps $SERVICE_NAME --format "{{.Name}}" --filter "desired-state=running")

echo "Found containers: $CONTAINERS"

# Test each container
for container in $CONTAINERS; do
    echo "Testing container: $container"
    
    # Get container info
    echo "Container info:"
    docker inspect $container --format "{{.Status.ContainerStatus.ContainerID}}"
    
    # Test node connectivity
    echo "Testing node connectivity for $container:"
    docker exec $container bin/kanban remote <<EOF
Node.list
:inet_res.lookup(:"tasks.web", :in, :a)
System.get_env("NODE_NAME")
System.get_env("ERLANG_COOKIE")
EOF
    echo "---"
done

echo "Cluster test completed!"
