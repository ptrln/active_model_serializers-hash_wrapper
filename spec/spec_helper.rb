require 'bundler'

Bundler.require(:default, :test)

require "simplecov"
SimpleCov.start

require 'active_model_serializers/hash_wrapper'
