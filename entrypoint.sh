RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake db:migrate

chown -R app:app db
chown -R app:app public
chown -R app:app private

/sbin/my_init