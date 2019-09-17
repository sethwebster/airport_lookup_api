BN=$(git rev-list --count HEAD)
docker build . -t registry.gitlab.com/sethwebster/airport_lookup_api:$BN
