require 'ulid/version'
require 'ulid/generator'
require 'ulid/decoder'

module ULID
  extend Generator
  extend Decoder
end
