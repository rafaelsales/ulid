require 'spec_helper'
require 'base32/crockford'

describe ULID do
  describe 'textual representation' do
    it 'ensures it has 26 chars' do
      ulid = ULID.generate

      ulid.length.must_equal 26
    end

    it 'is sortable' do
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
      # https://github.com/ulid/javascript#seed-time
      #
      # N.b. we avoid specifying the time as a float, since we lose precision:
      #
      # > Time.at(1_469_918_176.385).strftime("%F %T.%N")
      # => "2016-07-30 23:36:16.384999990"
      #
      # vs the correct:
      #
      # > Time.at(1_469_918_176, 385, :millisecond).strftime("%F %T.%N")
      # => "2016-07-30 23:36:16.385000000"
      ulid = ULID.generate(Time.at(1_469_918_176, 385, :millisecond))
      assert_equal '01ARYZ6S41', ulid[0...10]
    end

    it 'respects millisecond-precision order' do
      ulids = Array.new(1000) do |millis|
        time = Time.new(2020, 1, 2, 3, 4, Rational(millis, 10**3))

        ULID.generate(time)
      end

      assert_equal(ulids, ulids.sort)
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
      ULID.stub(:random_bytes, random_bytes) do
        bytes = ULID.generate_bytes
        assert bytes[6..-1] == random_bytes
      end
    end
  end
end
