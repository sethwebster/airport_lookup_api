BN=$(git rev-list --count HEAD)
kubectl --record deployment.apps/airport-icao-lookup set image deployment.v1.apps/airport-icao-lookup airport-icao-lookup=registry.gitlab.com/sethwebster/airport_lookup_api:$BN
echo "Set to version $BN"
