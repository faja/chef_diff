#
# Author:: Marcin Cabaj (<mcabaj@gmail.com>)
#

module ChefDiff
  class DataBagItem < ChefDiff::Item

    def initialize(databag, item, workdirpath = '.', chef_config_file = '~/.chef/knife.rb')
      @databag = databag
      @item = item
      @workdirpath = File.expand_path(workdirpath)
      @chef_config_file = File.expand_path(chef_config_file)
    end

    def load_from_file
      begin
        ff = JSON.parse(File.open(File.expand_path(File.join(@workdirpath,'data_bags',@databag,@item+'.json'),'r')).read)
      rescue
        return {}
      end
      return ff
    end

    def load_from_chef
      Chef::Config.from_file(@chef_config_file)
      fc = Chef::DataBagItem.load(@databag,@item).raw_data
      return fc
    end

    def self.list_from_chef(databag, chef_config_file='~/.chef/knife.rb')
      Chef::Config.from_file(File.expand_path(chef_config_file))
      Chef::DataBag.load(databag).keys
    end

  end
end
