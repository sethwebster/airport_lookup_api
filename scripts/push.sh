BN=$(git rev-list --count HEAD)
docker push registry.gitlab.com/sethwebster/airport_lookup_api:$BN
