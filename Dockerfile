FROM ruby:3.3-slim-bullseye

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libpq-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

COPY views/ ./views
COPY config.ru app.rb ./

CMD [ "rackup", "--host", "0", "-p", "4321" ]