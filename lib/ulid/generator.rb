require 'sysrandom'

module ULID
  class Generator
    ENCODING = '0123456789ABCDEFGHJKMNPQRSTVWXYZ' # Crockford's Base32
    RANDOM_BYTES = 10
    ENCODED_LENGTH = 26

    MASK = 0x1f

    def generate
      input = octo_word
      (1..ENCODED_LENGTH).to_a.reduce("") do |s, n|
        s + ENCODING[(input >> (128 - 5*n)) & MASK]
      end
    end

    private

    def octo_word
      (hi, lo) = genbytes.unpack("Q>Q>")
      (hi << 64) | lo
    end

    def genbytes
      forty_eight_bit_time + random_bytes
    end

    def forty_eight_bit_time
      hundred_micro_time = Time.now_100usec
      [hundred_micro_time].pack("Q>")[2..-1]
    end

    def random_bytes
      Sysrandom.random_bytes(RANDOM_BYTES)
    end
  end
end
