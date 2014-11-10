#
# Author:: Marcin Cabaj (<mcabaj@gmail.com>)
#

require 'chef'

module ChefDiff
  class DataBag

    def self.list_from_chef(chef_config_file='~/.chef/knife.rb')
      Chef::Config.from_file(File.expand_path(chef_config_file))
      Chef::DataBag.list.keys
    end

    def self.filter(array, patterns)
      raise "Wrong type of argument, first argument needs to be Array" unless array.is_a?(Array)
      raise "Wrong type of argument, second argument needs to be Array" unless patterns.is_a?(Array)
      ret_array=[]
      patterns.each do |pat|
        ret_array += array.select {|a| a[/#{pat}/]}
      end
      ret_array.uniq!
      ret_array
    end

  end
end
