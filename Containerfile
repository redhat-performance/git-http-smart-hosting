FROM registry.access.redhat.com/ubi9/ubi-init

# Install git
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf -y install git-core nginx fcgiwrap \
    && dnf clean all
RUN systemctl enable nginx.service fcgiwrap@nginx.service
ADD nginx.conf /etc/nginx/nginx.conf

# Nginx welcome page
RUN mkdir /srv/nginx \
    && echo "<h1>Hello world</h1>" >/srv/nginx/index.html

# fcgiwrap tuning
# Tested it with:
#    for i in $( seq 1000 ); do
#        ( mkdir -p repo$i && cd repo$i && time git clone --depth 1 http://localhost:8080/golang-docker-build-tutorial.git &>../repo$i.log ) &
#    done
# And with "10", 162 failed, with "100" all passed and it took about 8 seconds.
RUN sed -i 's/DAEMON_PROCS=.*/DAEMON_PROCS=100/' /etc/sysconfig/fcgiwrap

# Prepare repo to be served
# https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols#_dumb_http
RUN mkdir /srv/git \
    && cd /srv/git \
    && git clone --bare https://github.com/concaf/golang-docker-build-tutorial golang-docker-build-tutorial.git \
    && cd golang-docker-build-tutorial.git/ \
    && git update-server-info \
    && mv hooks/post-update.sample hooks/post-update \
    && chmod a+x hooks/post-update \
    && chown -R 1001:0 ./

# Build with:
#    podman build -t build-image-nginx -f Containerfile .
# Run with:
#    podman run --rm -ti -p 8080:8080 --name build-image-nginx build-image-nginx
# Clone from it with:
#    git clone http://localhost:8080/golang-docker-build-tutorial.git
