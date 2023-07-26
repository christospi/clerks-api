# Install libvips for Active Storage preview support
RUN apt-get update -qq && \
    apt-get install -y build-essential libvips libffi-dev bash bash-completion postgresql-client curl && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man
