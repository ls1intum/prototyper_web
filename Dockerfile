FROM phusion/passenger-ruby24

ARG secret_token
ENV SECRET_KEY_BASE=$secret_token

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN rm -f /etc/service/nginx/down

# Copy application code
COPY --chown=app:app . /home/app/prototyper_web

# Change to the application's directory
WORKDIR /home/app/prototyper_web

RUN rm /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/sites-enabled/webapp.conf

# Set Rails environment to production
ENV RAILS_ENV production

RUN apt-get update && \
    apt-get install -y imagemagick libmagickcore-dev libmagickwand-dev && \
    bundle install --deployment --without development test && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN RAILS_ENV=production bundle exec rake assets:precompile

