#!/usr/bin/env bash

get_aws_api_token() {
  curl -X PUT "http://169.254.169.254/latest/api/token" \
       -H "X-aws-ec2-metadata-token-ttl-seconds: 3600"
}

get_instance_meta_data() {
  local API_TOKEN=$1
  local META_DATA_ATTRIBUTE_NAME=$2
  curl -H "X-aws-ec2-metadata-token: $API_TOKEN" \
        "http://169.254.169.254/latest/meta-data/$META_DATA_ATTRIBUTE_NAME"
}

# get swarm token
while true; do
  TOKEN=$(aws ssm get-parameter \
            --name "/docker/swarm_manager_token" \
            --query "Parameter.Value" --output text \
            --with-decryption)
  if [ -n "$TOKEN" ] && [ "$TOKEN" != "NONE" ]; then 
    break
  fi
  echo "Waiting for Swarm Manager token..."
  sleep 2
done

# get primary node's IP
MANAGER_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${manager_tag}" \
              "Name=instance-state-name,Values=running" \
              "Name=tag:SwarmReady,Values=true" \
    --query "Reservations[0].Instances[0].PrivateIpAddress" \
    --region "${region}" --output text)

# validate manager IP
if [ -z "$MANAGER_IP" ] || [ "$MANAGER_IP" = "None" ]; then
  echo "Error: Could not find manager IP. Exiting."
  exit 1
fi

echo "Found manager IP: $MANAGER_IP"

# wait for manager to be ready
echo "Waiting for manager to be ready..."
while ! nc -z -v -w1 "$MANAGER_IP" 2377; do
  echo "Manager not ready yet, waiting..."
  sleep 5
done
echo "Manager is ready"

# join swarm with retry logic
echo "Attempting to join swarm with manager IP: $MANAGER_IP"
MAX_RETRIES=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  echo "Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES"
  
  if docker swarm join --token "$TOKEN" "$MANAGER_IP:2377"; then
    echo "Successfully joined swarm"
    break
  else
    echo "Failed to join swarm. Retrying in 10 seconds..."
    sleep 10
    RETRY_COUNT=$((RETRY_COUNT + 1))
  fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
  echo "Failed to join swarm after $MAX_RETRIES attempts. Exiting."
  exit 1
fi

# ensure port 22 is open
AWS_API_TOKEN=$(get_aws_api_token)
CURRENT_INSTANCE_IP=$(get_instance_meta_data "$AWS_API_TOKEN" "public-ipv4")

while ! nc -z -v -w1 "$CURRENT_INSTANCE_IP" 22; do
  echo "Waiting for SSH to be available..."
  sleep 2
done

# add "SwarmReady" tag
CURRENT_INSTANCE_ID=$(get_instance_meta_data "$AWS_API_TOKEN" "instance-id")

aws ec2 create-tags \
    --resources "$CURRENT_INSTANCE_ID" \
    --tags "Key=SwarmReady,Value=true" \
    --region "${region}"
