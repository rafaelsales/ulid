Dir.glob(File.join(__dir__, 'ulid/**/*.rb')).sort.each { |f| require f }

module ULID
  extend Generator
end
