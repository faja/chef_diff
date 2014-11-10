#
# Author:: Marcin Cabaj (<mcabaj@gmail.com>)
#

require 'json'

module ChefDiff
  class Config

  def initialize(configfile=File.join(File.dirname(__FILE__), '../../conf/conf.json'))
    @config_json=File.open(configfile,'r').read
    @config_hash=JSON.parse(@config_json)
  end

  %w[environments roles databags].each do |item|
    define_method(item) do
      return [] unless @config_hash["patterns"][item]
      @config_hash["patterns"][item]
    end
  end

  def chef_config_file
    @config_hash["chef_config_file"]
  end

  end
end
