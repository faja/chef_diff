#
# Author:: Marcin Cabaj (<mcabaj@gmail.com>)
#

module ChefDiff
  class Role < ChefDiff::Item
  
  def initialize(name = 'base', workdirpath = '.', chef_config_file = '~/.chef/knife.rb')
    @item = 'Role'
    @name = name
    @workdirpath = File.expand_path(workdirpath)
    @chef_config_file = File.expand_path(chef_config_file)
  end

  end
end
