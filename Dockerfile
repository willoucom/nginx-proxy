FROM nginx:1.13
LABEL maintainer="Jason Wilder mail@jasonwilder.com"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    curl \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install forego
ARG FOREGO_VERSION=ekMN3bCZFUn
RUN curl -Lks https://bin.equinox.io/c/$FOREGO_VERSION/forego-stable-linux-amd64.tgz \
    --output /forego.tar.gz \
    && tar -C /usr/local/bin -xvzf /forego.tar.gz \
    && rm /forego.tar.gz \
    && chmod u+x /usr/local/bin/forego

# Install docker-gen
ARG DOCKER_GEN_VERSION=0.7.4
RUN curl -Lks https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    --output /docker-gen.tar.gz \
    && tar -C /usr/local/bin -xvzf /docker-gen.tar.gz \
    && rm /docker-gen.tar.gz \
    && chmod u+x /usr/local/bin/docker-gen

# Install health check
RUN curl -Lks https://github.com/willoucom/docker-socket-healthcheck/releases/download/latest/docker-socket-healthcheck.tar.gz \
    --output /docker-socket-healthcheck.tar.gz \
    && tar -C /usr/local/bin -xvzf /docker-socket-healthcheck.tar.gz \
    && rm /docker-socket-healthcheck.tar.gz \
    && chmod u+x /usr/local/bin/docker-socket-healthcheck

# nginx configuration
COPY network_internal.conf /etc/nginx/

# Copy files into /app
COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start"]
