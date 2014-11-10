#
# Author:: Marcin Cabaj (<mcabaj@gmail.com>)
#

require 'chef'
require 'hashdiff'
require 'json'

module ChefDiff
  class Item

    def initialize(item, name, workdirpath='.',chef_config_file='~/.chef/knife.rb')
      supported_items=['environment','role']
      raise "Wrong type of item, use one of #{supported_items}" unless supported_items.include?(item)
      @item=item.capitalize
      @name=name
      @workdirpath=File.expand_path(workdirpath)
      @chef_config_file=File.expand_path(chef_config_file)
    end

    def load_from_file
      ff = Chef.const_get(@item).new
      ff.name(@name)
      begin
        ff.from_file(File.join(@workdirpath,"#{@item.downcase}s","#{@name}.rb"))
      rescue IOError
        return {}
      end
      return ff.to_hash
    end

    def load_from_chef
      Chef::Config.from_file(@chef_config_file)
      fc = Chef.const_get(@item).load(@name)
      return fc.to_hash
    end

    def equal?
      diff_array = HashDiff.diff(self.load_from_chef,self.load_from_file)
      return false unless diff_array.empty?
      true
    end

    def diff
#      HashDiff.diff(self.load_from_chef,self.load_from_file)
      HashDiff.diff(self.load_from_file,self.load_from_chef)
    end

    def print_diff
      output_string = ''
      self.diff.each do |item|
        if item[0] == '~'
          output_string << "+\t#{item[1]}\t#{item[3]}"
          output_string << "\n"
          output_string << "-\t#{item[1]}\t#{item[2]}"
          output_string << "\n"
        else
          output_string << item.join("\t")
          output_string << "\n"
        end
      end
      output_string
    end

    def self.list_from_chef(chef_config_file='~/.chef/knife.rb')
      Chef::Config.from_file(File.expand_path(chef_config_file))
      Chef.const_get(self.to_s.split('::')[1]).list.keys
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
