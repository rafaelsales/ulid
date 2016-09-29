require 'sysrandom'

module ULID
  module Generator
    ENCODING = '0123456789ABCDEFGHJKMNPQRSTVWXYZ' # Crockford's Base32
    RANDOM_BYTES = 10
    ENCODED_LENGTH = 26
    BIT_LENGTH = 128
    BITS_PER_B32_CHAR = 5

    MASK = 0x1f

    def generate
      input = octo_word
      (1..ENCODED_LENGTH).to_a.reduce("") do |s, n|
        shift = BIT_LENGTH - BITS_PER_B32_CHAR * n
        s + ENCODING[(input >> shift) & MASK]
      end
    end

    def generate_bytes
      time_48bit + random_bytes
    end

    private

    def octo_word
      (hi, lo) = generate_bytes.unpack("Q>Q>")
      (hi << 64) | lo
    end

    def time_48bit
      hundred_micro_time = Time.now_100usec
      [hundred_micro_time].pack("Q>")[2..-1]
    end

    def random_bytes
      Sysrandom.random_bytes(RANDOM_BYTES)
    end
  end
end
