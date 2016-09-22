require 'spec_helper'
require 'timecop'
require 'base32'

describe ULID do
  it "ensures it has 26 chars" do
    ulid = ULID.generate

    ulid.length.must_equal 26
  end

  it "is sortable" do
    ulid_1, ulid_2 = nil
    Timecop.freeze do
      ulid_1 = ULID.generate
      Timecop.travel Time.now + 20
      ulid_2 = ULID.generate
    end
    assert ulid_2 > ulid_1
  end

  before do
    Base32.table = ULID::Generator::ENCODING
  end
  
  it "encodes the timestamp in the high 48 bits" do
    Timecop.freeze do
      now = Time.now
      ulid = ULID.generate
      decoded = Base32.decode(ulid)
      ts = ("\x0\x0" + decoded[0...6]).unpack("Q>").first
      assert ts == (now.to_f * 10_000).to_i
    end
  end

end

