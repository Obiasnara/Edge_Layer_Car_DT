FROM debian:stable-slim

# Update package repositories
RUN apt update
# Upgrade all packages
RUN apt upgrade -y
# Install Nginx
# Install the libnginx-mod-rtmp module
RUN apt install -y nginx \ 
    libnginx-mod-rtmp \ 
    tcpdump \ 
    coturn

RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Create the directories for the HLS stream files
RUN cd /var/www/html/ && mkdir src

RUN cd /var/www/html/src/ && mkdir hls
RUN cd /var/www/html/src/ && mkdir rec

# Copy your custom nginx.conf file to the appropriate location

RUN chown -R www-data:www-data /var/www/html/src

# Remove the default Nginx configuration file
RUN rm /etc/nginx/sites-enabled/default
RUN rm /etc/nginx/sites-available/default
RUN rm /var/www/html/index.nginx-debian.html
# Expose port 80 for HTTP traffic
EXPOSE 80
# Expose port 1935 for RTMP traffic
EXPOSE 1935
# Expose port 443 for HTTPS traffic
EXPOSE 443

# Set environment variable for desired IP address
ENV CONTAINER_IP 172.17.0.2/16

# Enable TURN server via coturn
COPY turnserver.conf /etc/turnserver.conf
# Start Coturn server by decomenting TURN_SERVER_ENABLED=1 in /etc/default/coturn
RUN sed -i 's/#TURNSERVER_ENABLED=1/TURNSERVER_ENABLED=1/g' /etc/default/coturn

# Handle the certificate generation
# Set default passphrase if not provided
ARG PASSPHRASE=1234

# Install openssl package
RUN apt-get update && apt-get install -y openssl

# Create directories for certificate files
RUN mkdir -p /etc/ssl/certs && mkdir -p /etc/ssl/private
# Generate a private key without passphrase
RUN openssl genpkey -algorithm RSA -out /etc/ssl/private/turn_server_pkey.pem

# Generate a certificate signing request (CSR) for the private key
RUN openssl req -new -key /etc/ssl/private/turn_server_pkey.pem -out /etc/ssl/private/turn_server_csr.pem -subj "/C=/ST=/L=/O=Corp/OU=/CN="

# Self-sign the certificate
RUN openssl x509 -req -days 365 -in /etc/ssl/private/turn_server_csr.pem -signkey /etc/ssl/private/turn_server_pkey.pem -out /etc/ssl/private/turn_server_cert.pem

# Nginx certificate generation
# Generate a private key without passphrase
RUN openssl genpkey -algorithm RSA -out /etc/ssl/private/nginxHTTPS_pkey.pem
# Generate a certificate signing request (CSR) for the private key
RUN openssl req -new -key /etc/ssl/private/nginxHTTPS_pkey.pem -out /etc/ssl/private/nginxHTTPS_csr.pem -subj "/C=/ST=/L=/O=Corp/OU=/CN="

# Self-sign the certificate
RUN openssl x509 -req -days 365 -in /etc/ssl/private/nginxHTTPS_csr.pem -signkey /etc/ssl/private/nginxHTTPS_pkey.pem -out /etc/ssl/private/nginxHTTPS_cert.pem

# Set permissions for private key and certificates
#RUN chmod 644 /etc/ssl/private/turn_server_pkey.pem && chmod 644 /etc/ssl/private/turn_server_csr.pem /etc/ssl/private/turn_server_cert.pem


COPY nginx.conf /etc/nginx/nginx.conf
COPY test.html /var/www/html/src/test.html

# Start Nginx in the foreground when the container starts
CMD ["/bin/bash", "-c", "echo 'Setting up IP address...' && /sbin/ip addr replace ${CONTAINER_IP} dev eth0 && nginx -g 'daemon off;' && echo 'Starting TURN server...' && sudo iptables -A INPUT -p udp --dport 3478 -j ACCEPT sudo iptables -A INPUT -p udp --dport 5349 -j ACCEPT"]


