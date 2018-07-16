

case node['platform_family']
when 'rhel', 'fedora', 'amazon'
  default['nodeAuto']['package']['list'] = %w(memcached mariadb)
when 'debian'
  default['nodeAuto']['package']['list'] = %w(memcached mysql-server)
else
  default['nodeAuto']['package']['list'] = %w(memcached)
end
