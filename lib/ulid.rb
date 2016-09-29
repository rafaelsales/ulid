Dir.glob(File.join(File.dirname(__FILE__), "/**/*.rb")).sort.each { |f| require f }

module ULID
  extend Generator
end
