FROM ruby:3.4-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libjemalloc2 \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# install node https://github.com/nodesource/distributions
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
    apt-get install -y nodejs

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

COPY views/ ./views
COPY config.ru app.rb ./

CMD [ "rackup", "-s", "puma", "--host", "0", "-p", "4321" ]