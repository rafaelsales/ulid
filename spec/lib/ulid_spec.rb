require 'spec_helper'
require 'base32/crockford'

describe ULID do
  describe 'textual representation' do
    it 'ensures it has 26 chars' do
      ulid = ULID.generate

      ulid.length.must_equal 26
    end

    it 'is sortable' do
      ulid1, ulid2 = nil
      input_time = Time.now
      ulid1 = ULID.generate(input_time)
      ulid2 = ULID.generate(input_time + 1)
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
      ulid = ULID.generate(Time.at(1_469_918_176.385))
      assert_equal '01ARYZ6S41', ulid[0...10]
    end
  end

  describe 'underlying binary' do
    it 'encodes the timestamp in the high 48 bits' do
      input_time = Time.now.utc
      bytes = ULID.generate_bytes(input_time)
      (time_ms,) = "\x0\x0#{bytes[0...6]}".unpack('Q>')
      encoded_time = Time.at(time_ms / 1000.0).utc
      assert_in_delta input_time, encoded_time, 0.001
    end

    it 'encodes the remaining 80 bits as random' do
      random_bytes = SecureRandom.random_bytes(ULID::Generator::RANDOM_BYTES)
      ULID.stubs(:random_bytes).returns(random_bytes)
      bytes = ULID.generate_bytes
      assert bytes[6..-1] == random_bytes
    end
  end
end
