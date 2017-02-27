# ActiveModelSerializers::HashWrapper

Automatically create wrapper classes for Hashes so ActiveModelSerializers will serialize your hash!

[![Code Climate](https://lima.codeclimate.com/github/ptrln/active_model_serializers-hash_wrapper/badges/gpa.svg)](https://lima.codeclimate.com/github/ptrln/active_model_serializers-hash_wrapper)

[![Test Coverage](https://lima.codeclimate.com/github/ptrln/active_model_serializers-hash_wrapper/badges/coverage.svg)](https://lima.codeclimate.com/github/ptrln/active_model_serializers-hash_wrapper/coverage)

[![Issue Count](https://lima.codeclimate.com/github/ptrln/active_model_serializers-hash_wrapper/badges/issue_count.svg)](https://lima.codeclimate.com/github/ptrln/active_model_serializers-hash_wrapper)

[![Build Status](https://travis-ci.org/ptrln/active_model_serializers-hash_wrapper.svg?branch=master)](https://travis-ci.org/ptrln/active_model_serializers-hash_wrapper)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_model_serializers-hash_wrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_model_serializers-hash_wrapper

## Usage

Let's say you have a hash, and you would like AMS to serialize it. You can create a wrapper class for your hash like so:

```ruby
item_class = ActiveModelSerializers::HashWrapper.wrapper_class("Item")
wrapped_item = item_class.new(hash)
```

Or, for simplicity, you can do all this in one line:

```ruby
wrapped_item = ActiveModelSerializers::HashWrapper.create("Item", hash)
```

Wrapper classes created by `ActiveModelSerializers::HashWrapper` are passes all AMS lint tests and can safely be used.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ptrln/active_model_serializers-hash_wrapper.

