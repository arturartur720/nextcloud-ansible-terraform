#!/bin/bash

# Nextcloud post-installation configuration script
# This script runs after the initial Nextcloud installation

set -e

echo "Running Nextcloud post-installation configuration..."

# Configure Redis caching
echo "Configuring Redis caching..."
docker compose exec --user www-data app php occ config:system:set redis host --value='redis'
docker compose exec --user www-data app php occ config:system:set redis port --value='6379' --type=integer
docker compose exec --user www-data app php occ config:system:set redis timeout --value='0.0' --type=float
docker compose exec --user www-data app php occ config:system:set redis dbindex --value='0' --type=integer
docker compose exec --user www-data app php occ config:system:set memcache.local --value='\\OC\\Memcache\\Redis'
docker compose exec --user www-data app php occ config:system:set memcache.distributed --value='\\OC\\Memcache\\Redis'
docker compose exec --user www-data app php occ config:system:set memcache.locking --value='\\OC\\Memcache\\Redis'


# Run maintenance tasks
echo "Running maintenance tasks..."
docker compose exec --user www-data app php occ config:system:set maintenance_window_start --type=integer --value=1
docker compose exec --user www-data app php occ db:add-missing-indices
docker compose exec --user www-data app php occ db:add-missing-columns
docker compose exec --user www-data app php occ db:add-missing-primary-keys
docker compose exec --user www-data app php occ db:convert-filecache-bigint --no-interaction
docker compose exec --user www-data app php occ maintenance:repair --include-expensive

echo "Post-installation configuration completed!"