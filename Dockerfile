FROM ruby:3.0.0

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    gnupg2 \
    libxml2-dev \
    libxslt-dev \
    pkg-config \
    git \
    postgresql-client

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g yarn

WORKDIR /app

# Install bundler version compatible with Ruby 2.7.8
RUN gem install bundler:2.4.22

# Configure bundler to use force_ruby_platform globally
RUN bundle config set --global force_ruby_platform true

# Copy both Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --jobs 20 --retry 5

# Copy package.json and yarn.lock
COPY package.json ./

# Install node modules
RUN yarn install

# Copy the rest of the application
COPY . .

# Add the entrypoint script
# Copy the entrypoint scripts
COPY entrypoint.web.sh entrypoint.webpacker.sh ./
RUN chmod +x /app/entrypoint.web.sh /app/entrypoint.webpacker.sh

ENTRYPOINT ["/app/entrypoint.web.sh"]

EXPOSE 3000

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
