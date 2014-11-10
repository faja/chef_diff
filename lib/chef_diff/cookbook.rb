#
# Author:: Marcin Cabaj (<mcabaj@gmail.com>)
#

require 'find'
require 'digest'
require 'chef'

module ChefDiff
  class Cookbook
    
    def initialize(name, workdirpath = '.', chef_config_file = '~/.chef/knife.rb')
      @name = name
      @workdirpath = File.expand_path(workdirpath)
      @config = chef_config_file
      @tmp_dir = nil
      @rest = nil
    end

    def rest
      unless @rest
        Chef::Config.from_file(File.expand_path(@config))
        @rest = Chef::REST.new(Chef::Config[:chef_server_url])
      end
      @rest
    end

    def latest_version
      Chef::Config.from_file(File.expand_path(@config))
      versions = Chef::CookbookVersion.available_versions(@name)
      versions.sort!
      if versions.empty?
        raise "Can't find any version for cookbook #{@name}"
      end
      versions[-1]
    end 

    def is_in_git?(file)
      File.exists?(File.join(@workdirpath,'cookbooks',file))
    end

    def is_cookbook_in_git?
      self.is_in_git?(@name)
    end

    def cookbook_object
      self.rest.get_rest("cookbooks/#{@name}/#{self.latest_version}")
    end
    
    def download
      Chef::Config.from_file(File.expand_path(@config))
      cookbook_manifest = self.cookbook_object.manifest
      download_dir=File.join(self.tmp_dir,@name)
      Chef::CookbookVersion::COOKBOOK_SEGMENTS.each do |segment|
        next unless cookbook_manifest.has_key?(segment)
        cookbook_manifest[segment].each do |segment_file|
          dest = File.join(download_dir, segment_file['path'].gsub('/', File::SEPARATOR)) 
          FileUtils.mkdir_p(File.dirname(dest))
          self.rest.sign_on_redirect = false
          tempfile = self.rest.get_rest(segment_file['url'], true)
          FileUtils.mv(tempfile.path, dest)
        end
      end
    end

    def tmp_dir
      @tmp_dir||=Dir.mktmpdir
      @tmp_dir
    end

    def rm_tmp_dir
      return false unless @tmp_dir
      FileUtils.rm_rf(@tmp_dir)
      @tmp_dir = nil
      true
    end

    def cookbook_files
      return [] unless @tmp_dir
      files = []
      Find.find(File.join(self.tmp_dir,@name)) do |file|
        files << file unless File.directory?(file)
      end
      files
    end

    def diff
      diff = {:md5sum => [], :not_exist => []}
      self.cookbook_files.each do |file|
        chef_md5 = Digest::MD5.file(file).hexdigest

        file_array = file.split(File::SEPARATOR)
        tmp_dir_size = self.tmp_dir.split(File::SEPARATOR).size
        file_path = file_array[tmp_dir_size..-1].join(File::SEPARATOR)

        unless self.is_in_git?(file_path)
          diff[:not_exist] << file_path
          next
        end

        git_md5 = Digest::MD5.file(File.join(@workdirpath,'cookbooks',file_path)).hexdigest

        diff[:md5sum] << file_path unless chef_md5 == git_md5
      end
      diff
    end

    def self.list_from_chef(conf='~/.chef/knife.rb')
      chef_config_file = File.expand_path(conf)
      Chef::Config.from_file(chef_config_file)
      rest = Chef::REST.new(Chef::Config[:chef_server_url])
      all_cookbooks = rest.get_rest('/cookbooks?num_versions=1')
      all_cookbooks.keys
    end

  end
end
