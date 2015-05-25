export PUPPET_GEM_VERSION="~> 3.6.0"
export BUNDLE_GEMFILE=$PWD/Gemfile

rvm use 1.9.3 --install --binary --fuzzy

bundle install --without development


bundle exec rake travis

