FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    android-tools \
    bash \
    coreutils \
    tzdata

# Set working directory
WORKDIR /app

# The script will be mounted here
CMD ["/bin/bash", "/app/scheduler.sh"]
