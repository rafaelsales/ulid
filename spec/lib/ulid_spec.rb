require 'spec_helper'

describe ULID do
  it "ensures it has 26 chars" do
    ulid = ULID.generate

    ulid.length.must_equal 26
  end

  it "is sortable" do
    ulid_1 = ULID.generate
    ulid_2 = ULID.generate

    assert ulid_2 > ulid_1
  end
end

