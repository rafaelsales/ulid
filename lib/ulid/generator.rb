require 'sysrandom'

module ULID
  class Generator
    ENCODING = '0123456789ABCDEFGHJKMNPQRSTVWXYZ' # Crockford's Base32
    TIME_LENGTH = 10
    RANDOM_LENGTH = 16

    def generate
      encode_time(milliseconds_since_epoch, TIME_LENGTH) + encode_random(RANDOM_LENGTH)
    end

    private

    def encode_time(now, length)
      length.times.reduce('') do |output|
        mod = now % ENCODING.length
        now = (now - mod) / ENCODING.length

        output << ENCODING[mod]
      end.reverse
    end

    def encode_random(length)
      length.times.reduce("") do |output|
        random = Sysrandom.random_number(ENCODING.length)

        output << ENCODING[random]
      end.reverse
    end

    def milliseconds_since_epoch
      (Time.now.to_f * 1000).to_i
    end
  end
end
