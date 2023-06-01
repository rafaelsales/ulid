# frozen-string-literal: true

require 'ulid/generator'

module ULID
  module Decoder
    def decode_time(string)
      if string.size != Generator::ENCODED_LENGTH
        raise ArgumentError, 'string is not of ULID length'
      end

      epoch_time_ms = string.slice(0, 10).split('').reverse.each_with_index.reduce(0) do |carry, (char, index)|
        encoding_index = Generator::ENCODING.index(char.bytes.first)

        if encoding_index.nil?
          raise ArgumentError, "invalid character found: #{char}"
        end

        carry += encoding_index * (Generator::ENCODING.size**index).to_i
        carry
      end

      Time.at(0, epoch_time_ms, :millisecond)
    end
  end
end
