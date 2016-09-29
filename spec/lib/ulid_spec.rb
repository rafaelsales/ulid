require 'spec_helper'
require 'timecop'
require 'base32'

describe ULID do
  describe "textual representation" do
    it "ensures it has 26 chars" do
      ulid = ULID.generate

      ulid.length.must_equal 26
    end

    it "is sortable" do
      ulid_1, ulid_2 = nil
      Timecop.freeze do
        ulid_1 = ULID.generate
        Timecop.travel Time.now + 1
        ulid_2 = ULID.generate
      end
      assert ulid_2 > ulid_1
    end

    it "is valid Crockford Base32" do
      Base32.table = ULID::Generator::ENCODING
      ulid = ULID.generate
      decoded = Base32.decode(ulid)
      encoded = Base32.encode(decoded)[0...26]
      assert encoded == ulid
    end
  end

  describe "underlying binary" do

    it "encodes the timestamp in the high 48 bits" do
      Timecop.freeze do
        now_100usec = Time.now_100usec
        bytes = ULID.generate_bytes
        ts = ("\x0\x0" + bytes[0...6]).unpack("Q>").first
        assert ts == now_100usec
      end
    end

    it "encodes the remaining 80 bits as random" do
      random_bytes = Sysrandom.random_bytes(ULID::Generator::RANDOM_BYTES)
      ULID.stubs(:random_bytes).returns(random_bytes)
      bytes = ULID.generate_bytes
      assert bytes[6..-1] == random_bytes
    end
  end

end
