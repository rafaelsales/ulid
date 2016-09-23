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
  end

  describe "underlying binary" do
    before do
      Base32.table = ULID::Generator::ENCODING
    end

    it "encodes the timestamp in the high 48 bits" do
      Timecop.freeze do
        now_100usec = Time.now_100usec
        ulid = ULID.generate
        decoded = Base32.decode(ulid)
        ts = ("\x0\x0" + decoded[0...6]).unpack("Q>").first
        assert ts == now_100usec
      end
    end

    it "encodes the remaining 80 bits as random" do
      random_bytes = Sysrandom.random_bytes(ULID::Generator::RANDOM_BYTES)
      ULID::Generator.any_instance.stubs(:random_bytes).returns(random_bytes)
      ulid = ULID.generate
      decoded = Base32.decode(ulid)
      assert decoded[6..-1] == random_bytes
    end
  end

end
