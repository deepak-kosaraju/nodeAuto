require 'spec_helper'

describe 'nodeAuto::default' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html
  it 'does something' do
    skip 'Replace this with meaningful tests'
  end
end

%w(nginx memcached).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe group(node['nodeAuto']['node_js']['group']['name']) do
  it { should exist } 
end

describe user(node['nodeAuto']['node_js']['user']['name']) do
  it { should exist }
  it { should belong_to_primary_group node['nodeAuto']['node_js']['group']['name'] }
end

describe iptables do
  it { should have_rule('-A INPUT -p tcp -s 10.0.0.0/8 --dport 80 -j ACCEPT') }
end

describe file('/opt/app') do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by node['nodeAuto']['node_js']['user']['name'] }
end