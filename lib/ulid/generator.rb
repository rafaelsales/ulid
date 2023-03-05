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

    # Generates a ULID string based on the given or current time.
    def generate(time = Time.now)
      input = octo_word(time)

      encode(input, ENCODED_LENGTH)
    end

    # Generates a 128 bits string consisting of the first 48 bits being a timestamp
    # and the remaining 80 bits being random bytes.
    def generate_bytes(time = Time.now)
      time_48bit(time) + SecureRandom.random_bytes(RANDOM_BITS / 8)
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

    # Combines the timestamp and random bytes into a 128-bit integer.
    def octo_word(time = Time.now)
      (hi, lo) = generate_bytes(time).unpack('Q>Q>')
      (hi << 64) | lo
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
