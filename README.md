Repo serving pod
================

It is quite simple to serve a *bare git repo* via http. But if you need
e.g. shallow clones to work, you need "Smart HTTP" protocol, and to make
it running, plain webserver is not enough.

This container aims to provide a "Smart HTTP" server capable of serving
bare git repo for various testing purposes.

Image is available here:

    podman pull quay.io/rhcloudperfscale/openshift-pipelines_performance-utils-build-image-nginx

To build it locally:

    podman build -t git-http-smart-hosting -f Containerfile .

To run it locally:

    podman run -ti --rm -p 8080:8080 --name git-http-smart-hosting git-http-smart-hosting

And then to clone from it locally:

    git clone http://localhost:8080/golang-docker-build-tutorial.git

Locally, you can test performance and stability of the container with:

    podman run -ti --rm -p 8080:8080 --name git-http-smart-hosting git-http-smart-hosting

    mkdir /tmp/test_clones
    cd /tmp/test_clones
    date --utc -Ins >before
    for i in $( seq 1000 ); do
        ( mkdir -p repo$i && cd repo$i && time git clone --depth 1 http://localhost:8080/golang-docker-build-tutorial.git &>../repo$i.log ) &
    done
    wait
    date --utc -Ins >after

On my machine it all takes about 10 seconds.
