BN=$(git rev-list --count HEAD)
docker push sharetheair/airport-icao-lookup:$BN
