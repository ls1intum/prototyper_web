FROM ruby:2.4.9-stretch

# Copy application code
COPY . /prototyper_web
# Change to the application's directory
WORKDIR /prototyper_web

# Set Rails environment to production
ENV RAILS_ENV production

# Install gems, nodejs and precompile the assets
RUN bundle install --deployment --without development test \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt install -y nodejs

# Start the application server
ENTRYPOINT ./entrypoint.sh