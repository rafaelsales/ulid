# frozen-string-literal: true

require 'securerandom'

module ULID
  module Generator
    ENCODING = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'.bytes.freeze # Crockford's Base32
    RANDOM_BYTES = 10
    ENCODED_LENGTH = 26
    BIT_LENGTH = 128
    BITS_PER_B32_CHAR = 5
    ZERO = '0'.ord

    MASK = 0x1f

    def generate(time = Time.now, name = nil)
      input = octo_word(time, name)

      encode(input, ENCODED_LENGTH)
    end

    def generate_bytes(time = Time.now, name = nil)
      name_bytes = name.split('').map { |e| e.to_i(32) }.pack('C*') if name
      time_48bit(time) + (name_bytes || random_bytes)
    end

    private

    def encode(input, length)
      e = Array.new(length, ZERO)
      i = length - 1

      while input > 0
        e[i] = ENCODING[input & MASK]
        input >>= 5
        i -= 1
      end

      e.pack('c*')
    end

    def octo_word(time = Time.now, name = nil)
      (hi, lo) = generate_bytes(time, name).unpack('Q>Q>')
      if hi.nil? || lo.nil?
        raise ArgumentError, 'name string without hex encoding passed to ULID generator'
      end
      (hi << 64) | lo
    end

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

    def random_bytes
      SecureRandom.random_bytes(RANDOM_BYTES)
    end
  end
end
