# browser-screenshot-service

web browser screenshot as a service! Designed for the [mikenye ADSB decoding](https://mikenye.gitbook.io/ads-b/) world.

## execution example

```bash
    docker run -p 5042:5042 \
      -e MAP_ARGS='zoom=11&hideSidebar&hideButtons&mapDim=0.3' \
      -e BASE_URL='https://ramonk.net/tar1090/' -it tedder42/browser-screenshot-service:latest

    curl http://localhost:5042/snap/a9b67c
```

Fix the URL, make sure the ICAO actually exists, use upper or lower case. Some of the environment vars were listed to show what might be put in there.

There's a bit of sanity testing against the ICAO code in the URL. Enter something invalid and it'll return a 1x1 pixel.
