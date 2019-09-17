BN=$(git rev-list --count HEAD)
docker build . -t sharetheair/airport-icao-lookup:$BN
