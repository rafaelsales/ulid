require 'spec_helper'

describe ULID do
  it "works" do
    ulid = ULID.random_create
    ulid.length.must_equal 26
  end
end

