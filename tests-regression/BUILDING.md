# Building Containers

## Shell Script

The following shell scripts will build the images.

* build_all_nctest_images.sh

> Note, you should first fetch dependencies using the `prefetch-files.sh` script.

## Docker Compose

You can build the images as follows via `docker compose`

    $ docker compose -f docker-compose-base.yml build
    $ docker compose -f docker-compose-tests.yml build

