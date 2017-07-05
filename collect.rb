#!/usr/bin/env ruby

#
# Date ........: 07/05/2017
# Developers ..: Pablo Hess <phess@redhat.com> and Waldirio Pinheiro <waldirio@redhat.com>
# Description .: Collect some information from RHN hosts
# Changelog ...: 
#

require "xmlrpc/client"
require "io/console"
require "optparse"

@options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: collect.rb"

  opts.on("--credit", "Developer Team Members") do ||
    puts "Made by Pablo Hess and Waldirio Pinheiro"
    exit {}
  end

  opts.on("-u", "--user [USERNAME]", "Red Hat Network Username") do |u|
    @options[:username] = u
  end

  opts.on("-p", "--password [PASSWORD]", "Red Hat Network Password") do |p|
    @options[:password] = p
  end
  
end.parse!



def collect_user_data
  print "Type your RHNID Username: "
  @SATELLITE_LOGIN=gets.chomp

  print "Type your RHNID Password: "
  @SATELLITE_PASSWORD = STDIN.noecho(&:gets)

  return [@SATELLITE_LOGIN, @SATELLITE_PASSWORD]
end


def connect_rhn(user, password)
begin
  puts
  puts "Connecting to Red Hat Network....."

  @SATELLITE_URL = "http://xmlrpc.rhn.redhat.com/rpc/api"

  @client = XMLRPC::Client.new2(@SATELLITE_URL)

  @key = @client.call('auth.login', user, password)
	
  rescue XMLRPC::FaultException
    puts "Wrong password!"
    exit(5)
  end

  channels = @client.call('system.listUserSystems', @key)
  for channel in channels do
    puts channel["name"]
  end

  @client.call('auth.logout', @key)
end

# Just to see the Hash field content
# p @options[:username]
# p @options[:password]

# Main area
if @options[:username] and @options[:password]
	user = @options[:username]
	pass = @options[:password]
else
	user, pass = collect_user_data()
end

connect_rhn(user, pass)
