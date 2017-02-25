require 'spec_helper'

describe ActiveModelSerializers::HashWrapper do

  it "should have a version" do
    expect(::ActiveModelSerializers::HashWrapper::VERSION).to_not be_nil
  end

end
