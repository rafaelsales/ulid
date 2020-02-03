require 'spec_helper'
require 'timecop'
require 'base32/crockford'

describe ULID do
  describe 'textual representation' do
    it 'ensures it has 26 chars' do
      ulid = ULID.generate

      ulid.length.must_equal 26
    end

    it 'is sortable' do
      ulid1, ulid2 = nil
      Timecop.freeze do
        ulid1 = ULID.generate
        Timecop.travel Time.now + 1
        ulid2 = ULID.generate
      end
      assert ulid2 > ulid1
    end

    it 'is valid Crockford Base32' do
      ulid = ULID.generate
      decoded = Base32::Crockford.decode(ulid)
      encoded = Base32::Crockford.encode(decoded, length: 26)
      assert_equal ulid, encoded
    end

    it 'encodes the timestamp in the first 10 characters' do
      # test case taken from original ulid README:
      # https://github.com/alizain/ulid#seed-time
      Timecop.freeze(Time.at(1_469_918_176.385)) do
        ulid = ULID.generate(Time.at(1_469_918_176.385))
        assert_equal '01ARYZ6S41', ulid[0...10]
      end
    end
  end

  describe 'underlying binary' do
    it 'encodes the timestamp in the high 48 bits' do
      input_time = Time.now.utc
      Timecop.freeze(input_time) do
        bytes = ULID.generate_bytes
        (time_ms,) = "\x0\x0#{bytes[0...6]}".unpack('Q>')
        encoded_time = Time.at(time_ms / 1000.0).utc
        assert_in_delta input_time, encoded_time, 0.001
      end
    end

    it 'encodes the remaining 80 bits as random' do
      random_bytes = SecureRandom.random_bytes(ULID::Generator::RANDOM_BYTES)
      ULID.stub(:random_bytes, random_bytes) do
        bytes = ULID.generate_bytes
        assert bytes[6..-1] == random_bytes
      end
    end
  end
end
