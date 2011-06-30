require 'yaml'

# given:  h = {key => value}
# 1) add member:  attr_reader :key
# 2) set its value:  @key = value
module Properties
  def load(config_fn)
    @prop = YAML::load(File.open(config_fn))
    update! @prop
  end

  def update!(hash)
    hash.each do |key, value|
      # create => attr_reader :ikey
      self.instance_eval("class << self; attr_reader :#{key}; end")

      # set value for => attr_reader :key
      eval "@#{key}=value"
    end
  end
end
