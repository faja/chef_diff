#
# Author:: Marcin Cabaj (<mcabaj@gmail.com>)
#

module ChefDiff
  class Environment < ChefDiff::Item
  
  def initialize(name = '_default', workdirpath = '.', chef_config_file = '~/.chef/knife.rb')
    @item = 'Environment'
    @name = name
    @workdirpath = File.expand_path(workdirpath)
    @chef_config_file = File.expand_path(chef_config_file)
  end

  end
end
