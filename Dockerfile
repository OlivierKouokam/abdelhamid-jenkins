FROM alpine:3.17 AS files
LABEL maintainer='Abdelhamid YOUNES'

# Install git in a single RUN command to reduce image layers
RUN apk add --no-cache git && \
    mkdir /opt/files && \
    git clone https://github.com/diranetafen/static-website-example.git /opt/files/

# Second stage: use a slim Nginx base image
FROM nginx:stable-alpine AS webserver
LABEL maintainer='Abdelhamid YOUNES'

# Copy files from the previous stage
COPY --from=files /opt/files/ /usr/share/nginx/html/

# Expose port 80
#EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]