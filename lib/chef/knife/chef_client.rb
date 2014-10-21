require 'chef/knife'
require 'chef/knife/zero_base'
require 'knife-zero/bootstrap_ssh'

class Chef
  class Knife
    class ZeroChefClient < Chef::Knife::BootstrapSsh
      include Chef::Knife::ZeroBase

      banner "knife zero chef_client QUERY (options)"

      option :concurrency,
        :short => "-C NUM",
        :long => "--concurrency NUM",
        :description => "The number of concurrent connections",
        :default => nil,
        :proc => lambda { |o| o.to_i }

      option :attribute,
        :short => "-a ATTR",
        :long => "--attribute ATTR",
        :description => "The attribute to use for opening the connection - default depends on the context",
        :proc => Proc.new { |key| Chef::Config[:knife][:ssh_attribute] = key.strip }

      option :use_sudo,
        :long => "--sudo",
        :description => "execute the chef-client via sudo",
        :boolean => true

      def initialize(argv=[])
        super
        @name_args = [@name_args[0], start_chef_client]
      end

      def start_chef_client
        client_path = @config[:use_sudo] ? 'sudo ' : ''
        client_path = @config[:chef_client_path] ? "#{client_path}#{@config[:chef_client_path]}" : "#{client_path}chef-client"
        s = "#{client_path}"
        s << ' -l debug' if @config[:verbosity] and @config[:verbosity] >= 2
        s << " -S http://127.0.0.1:8889"
        s << " -W" if @config[:why_run]
        s
      end
    end
  end
end
