# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /demo_auth_app
WORKDIR /demo_auth_app
COPY Gemfile /demo_auth_app/Gemfile
COPY Gemfile.lock /demo_auth_app/Gemfile.lock
RUN bundle install
CMD ["bundle", "exec", "rails", "s"]
