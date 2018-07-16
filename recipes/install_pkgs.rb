# Upgrade unless its a Debian based Platform
unless node['platform_family'] == 'debian'
  package 'openssl-libs' do
    action :upgrade
  end
end

# Install list of packages of pkg_list
node['nodeAuto']['package']['list'].each do |pkg|
  package pkg do
    action :install
  end
end