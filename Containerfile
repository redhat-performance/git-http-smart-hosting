FROM registry.access.redhat.com/ubi9/ubi-minimal

# Install required packages
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && microdnf -y install supervisor git-core nginx fcgiwrap \
    && microdnf clean all

# Prepare repo to be served
# https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols#_dumb_http
RUN mkdir /srv/git \
    && cd /srv/git \
    && git clone --bare https://github.com/concaf/golang-docker-build-tutorial golang-docker-build-tutorial.git \
    && cd golang-docker-build-tutorial.git/ \
    && git update-server-info \
    && mv hooks/post-update.sample hooks/post-update \
    && chown -R 1001:0 ./ \
    && chmod ug+x hooks/post-update

# Nginx welcome page
RUN mkdir /srv/nginx \
    && echo "<h1>Hello world</h1>" >/srv/nginx/index.html

# Prepare dir for socket
RUN mkdir -p /srv/supervisord/run \
    && chown -R 1001:0 /srv/supervisord/run \
    && chmod -R og+rwx /srv/supervisord/run

# Prepare nginx logging
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Service configs
ADD supervisord.conf /etc/supervisord.conf
ADD nginx.conf /etc/nginx/nginx.conf
ADD fcgiwrap.conf /etc/sysconfig/fcgiwrap

WORKDIR /srv/git
USER 1001
EXPOSE 8080
CMD ["/usr/bin/supervisord"]
