require 'sysrandom'

module ULID
  module Generator
    ENCODING = '0123456789ABCDEFGHJKMNPQRSTVWXYZ' # Crockford's Base32
    RANDOM_BYTES = 10
    ENCODED_LENGTH = 26
    BIT_LENGTH = 128
    BITS_PER_B32_CHAR = 5

    MASK = 0x1f

    def generate(time = Time.now)
      input = octo_word(time)

      encode(input, ENCODED_LENGTH)
    end

    def generate_bytes(time = Time.now)
      time_48bit(time) + random_bytes
    end

    private

    def encode(n, length)
      e = "0" * length
      i = length - 1

      while n > 0
        e[i] = ENCODING[n & MASK]
        n >>= 5
        i -= 1
      end

      e
    end

    def octo_word(time = Time.now)
      (hi, lo) = generate_bytes(time).unpack("Q>Q>")
      (hi << 64) | lo
    end

    def time_48bit(time = Time.now)
      time_ms = (time.to_f * 1000).to_i
      [time_ms].pack("Q>")[2..-1]
    end

    def random_bytes
      Sysrandom.random_bytes(RANDOM_BYTES)
    end
  end
end
