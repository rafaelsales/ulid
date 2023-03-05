# frozen-string-literal: true

require 'securerandom'

module ULID
  module Generator
    ENCODING = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'.bytes.freeze # Crockford's Base32
    RANDOM_BITS = 80
    ENCODED_LENGTH = 26
    BITS_PER_B32_CHAR = 5
    ZERO = '0'.ord
    MASK = 0x1f

    # Generates a 128-bit ULID string.
    # @param [Time] time (Time.now) Timestamp - first 48 bits
    # @param [String] suffix (80 random bits) - the remaining 80 bits as hex encodable string
    def generate(time = Time.now, suffix: nil)
      (hi, lo) = generate_bytes(time, suffix: suffix).unpack('Q>Q>')
      if hi.nil? || lo.nil?
        raise ArgumentError, 'suffix string without hex encoding passed to ULID generator'
      end

      integer = (hi << 64) | lo
      encode(integer, ENCODED_LENGTH)
    end

    # Generates a 128-bit ULID.
    # @param [Time] time (Time.now) Timestamp - first 48 bits
    # @param [String] suffix (80 random bits) - the remaining 80 bits as hex encodable string
    def generate_bytes(time = Time.now, suffix: nil)
      suffix_bytes =
        if suffix
          suffix.split('').map { |char| char.to_i(32) }.pack('C*')
        else
          SecureRandom.random_bytes(RANDOM_BITS / 8)
        end

      time_48bit(time) + suffix_bytes
    end

    private

    # Encodes a 128-bit integer input as a 26-character ULID string using Crockford's Base32.
    def encode(input, length)
      encoded = Array.new(length, ZERO)
      i = length - 1

      while input > 0
        encoded[i] = ENCODING[input & MASK]
        input >>= BITS_PER_B32_CHAR
        i -= 1
      end

      encoded.pack('c*')
    end

    # Returns the first 6 bytes of a timestamp (in milliseconds since the Unix epoch) as a 48-bit byte string
    def time_48bit(time = Time.now)
      # Avoid `time.to_f` since we want to accurately represent a whole number of milliseconds:
      #
      # > time = Time.new(2020, 1, 5, 7, 3, Rational(2, 1000))
      # => 2020-01-05 07:03:00 +0000
      # > (time.to_f * 1000).to_i
      # => 1578207780001
      #
      # vs
      #
      # > (time.to_r * 1000).to_i
      # => 1578207780002
      time_ms = (time.to_r * 1000).to_i
      [time_ms].pack('Q>')[2..-1]
    end
  end
end
