module ULID
  def self.random_create
    Generator.new.random_create
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "/ulid/**/*.rb")).sort.each { |f| require f }
