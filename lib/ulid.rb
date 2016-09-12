module ULID
  def self.generate
    Generator.new.generate
  end
end

Dir.glob(File.join(File.dirname(__FILE__), '/ulid/**/*.rb')).sort.each { |f| require f }
