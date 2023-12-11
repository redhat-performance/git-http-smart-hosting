FROM registry.access.redhat.com/ubi9/nginx-120

# Install git
USER 0
RUN dnf -y install git-core \
    && dnf clean all

# Prepare repo to be served
# https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols#_dumb_http
RUN git clone --bare https://github.com/concaf/golang-docker-build-tutorial golang-docker-build-tutorial \
    && cd golang-docker-build-tutorial/ \
    && git update-server-info \
    && mv hooks/post-update.sample hooks/post-update \
    && chmod a+x hooks/post-update \
    && chown -R 1001:0 ./
USER 1001

# Build with:
#    podman build -t build-image-nginx -f Containerfile .
# Run with:
#    podman run --rm -ti -p 8080:8080 build-image-nginx
# Clone from it with:
#    git clone http://localhost:8080/golang-docker-build-tutorial/
CMD nginx -g "daemon off;"
