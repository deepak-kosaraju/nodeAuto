#
# Cookbook Name:: nodeAuto
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'nodeAuto::install_pkgs'
include_recipe 'nodejs'
include_recipe 'nginx'
include_recipe 'iptables'
include_recipe 'nodeAuto::application'

node['nodeAuto']['iptables']['rules'].map do |rule_name, rule_body|
  Chef::Log.info("RuleName is #{rule_name}, RuleBody is #{rule_body}")
  iptables_rule rule_name do
    lines [ rule_body ].flatten.join("\n")
  end
end