require 'spec_helper'
require 'minitest'

describe ActiveModelSerializers::HashWrapper do

  it "should have a version" do
    expect(::ActiveModelSerializers::HashWrapper::VERSION).to_not be_nil
  end

  describe "#wrapper_class" do

    it "should return a subclass of ActiveModelSerializers::Model" do
      expect(::ActiveModelSerializers::HashWrapper.wrapper_class("Item").superclass).to be ActiveModelSerializers::Model
    end

  end

  describe "#create" do

    let(:source_hash) do
      {id: 1, name: "Carrots"}
    end

    let(:wrapper) do
      ::ActiveModelSerializers::HashWrapper.create("Item", source_hash)
    end

    describe "ActiveModel::Serializer::Lint::Tests" do
      include ActiveModel::Serializer::Lint::Tests
      include Minitest::Assertions

      attr_accessor :assertions

      before(:each) do
        self.assertions = 0
        @resource = wrapper
      end

      ActiveModel::Serializer::Lint::Tests.public_instance_methods.map(&:to_s).grep(/^test/).each do |m|
        it(m) { send m }
      end

      def assert_instance_of(result, name)
        assert result.instance_of?(name), "#{result} should be an instance of #{name}"
      end
    end

  end

end
