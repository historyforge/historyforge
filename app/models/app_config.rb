class AppConfig
  def self.[](key)
    Setting.value_of(key)
  end

  def self.method_missing(method, *args)
    self[method]
  end
end