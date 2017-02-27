require 'spec_helper'
require 'minitest'

describe "ActiveModel::Serializer::Lint::Tests" do
  include ActiveModel::Serializer::Lint::Tests
  include Minitest::Assertions

  attr_accessor :assertions

  before(:each) do
    self.assertions = 0
    @resource = ::ActiveModelSerializers::HashWrapper.create("Item", {})
  end

  ActiveModel::Serializer::Lint::Tests.public_instance_methods.map(&:to_s).grep(/^test/).each do |m|
    it(m) { send m }
  end

  def assert_instance_of(result, name)
    assert result.instance_of?(name), "#{result} should be an instance of #{name}"
  end
end
