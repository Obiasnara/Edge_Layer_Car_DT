FROM eclipse-mosquitto

# Copy the configuration file
COPY ./config /mosquitto/config

# Expose the MQTT ports
EXPOSE 1883
EXPOSE 9001

# Create directories for certificates and a password file
RUN mkdir -p /mosquitto/certs /mosquitto/password

# Install OpenSSL using apk
RUN apk add --no-cache openssl

# Generate CA certificate and key
# IMPORTANT: Generate these files separately and copy them into the image using `COPY`
RUN openssl req -x509 -newkey rsa:4096 \
    -keyout /mosquitto/certs/ca.key \
    -out /mosquitto/certs/ca.crt \
    -days 36500 \
    -nodes \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=mosquitto"

# Generate server certificate and key
RUN openssl req -newkey rsa:2048 \
    -keyout /mosquitto/certs/mosquitto.key \
    -out /mosquitto/certs/mosquitto.csr \
    -nodes \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=mosquitto"

#  The -extfile option is used to specify the configuration file that contains the subjectAltName extension
RUN openssl x509 -req -in /mosquitto/certs/mosquitto.csr \
    -CA /mosquitto/certs/ca.crt \
    -CAkey /mosquitto/certs/ca.key \
    -CAcreateserial \
    -out /mosquitto/certs/mosquitto.crt \
    -days 36500 \
    -extfile /mosquitto/config/openssl.cnf

# Copy the certificates into the ca-certs directory
# RUN cp /mosquitto/certs/ca.crt /etc/ca-certificates/
# Create a password file for mosquitto authentication
# IMPORTANT: Generate this file separately and copy it into the image using `COPY`

# Start the MQTT broker while adjusting the paths to certificates 
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]