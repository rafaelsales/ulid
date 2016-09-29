class Time
  def self.now_100usec
    (now.to_f * 10_000).to_i
  end
end
