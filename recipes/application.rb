# default app directory
directory node['nodeAuto']['node_js']['default_app_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Group for user who runs node apps
group node['nodeAuto']['node_js']['group']['name'] do
  gid node['nodeAuto']['node_js']['group']['id']
  action :create
end

# User used to run node apps
user node['nodeAuto']['node_js']['user']['name'] do
  comment 'Use to run node and manage applications'
  uid node['nodeAuto']['node_js']['user']['id']
  gid node['nodeAuto']['node_js']['group']['id']
  home node['nodeAuto']['node_js']['default_app_dir']
  shell node['nodeAuto']['node_js']['user']['shell']
  action :create
  only_if 'grep node-web /etc/group'
end

## Loop through dict of nodeAuto.node_js.app attribute to configure each app based on their parameters
node['nodeAuto']['node_js']['app'].each_key do |app_name|
  if node['nodeAuto']['node_js']['app'][app_name]['enable']
    source_file = node['nodeAuto']['node_js']['app'][app_name]['dir'] + '/' + node['nodeAuto']['node_js']['app'][app_name]['file']

    Chef::Log.debug("Application: #{app_name} is Enable on this host #{node['name']}, so Source file for App: #{app_name} is: #{source_file}")
    ## Directory to place application files
    directory node['nodeAuto']['node_js']['app'][app_name]['dir'] do
      owner node['nodeAuto']['node_js']['user']['name']
      group node['nodeAuto']['node_js']['group']['name']
      mode node['nodeAuto']['node_js']['app'][app_name]['dir_mode']
      recursive true
      action :create
    end

    ## directory for application log
    directory node['nodeAuto']['node_js']['app'][app_name]['log_dir'] do
      owner node['nodeAuto']['node_js']['user']['name']
      group node['nodeAuto']['node_js']['group']['name']
      mode '0755'
      recursive true
      action :create
    end
    
    ## copy app.js from files/default/ to app home dir
    template source_file do
      source 'app.js.erb'
      owner node['nodeAuto']['node_js']['user']['name']
      group node['nodeAuto']['node_js']['group']['name']
      mode node['nodeAuto']['node_js']['app'][app_name]['file_mode']
      variables(
        app: node['nodeAuto']['node_js']['app'][app_name]
        )
      action :create
      only_if { Dir.exist?(node['nodeAuto']['node_js']['app'][app_name]['dir']) }
    end

    # if node platform is ubuntu and version is <= 15.04 use upstart, starting from 15.04 upstart was replaced by systemd
    if node['platform'] == 'ubuntu' && node['platform_version'] < '15.04'
      init_file = "/etc/init/#{app_name}.conf"
      execute "init-checkconf_#{app_name}" do
        command "/usr/bin/init-checkconf #{init_file}"
        action :nothing
      end
      ## Template file to create upstart init conf file
      template init_file do
        source 'upstart.erb'
        owner node['nodeAuto']['node_js']['user']['name']
        group node['nodeAuto']['node_js']['group']['name']
        mode '0755'
        variables(
          init_conf: node['nodeAuto']['node_js']['app'][app_name] 
          )
        action :create
        notifies :run, "execute[init-checkconf_#{app_name}]", :immediately
      end
      ## service to ensure application is started
      service app_name do
        action [:enable, :start]
        subscribes :reload, "execute[init-checkconf_#{app_name}]", :immediately
        subscribes :reload, "template[#{source_file}]"
      end
    else
      ## Configure systemd to manage the application under service manager
      service_file = "#{app_name}.service" 
      systemd_unit service_file do
        content(
          node['nodeAuto']['node_js']['app'][app_name]['systemd']
          )
        # user node['nodeAuto']['node_js']['user']['name']
        action :create
        action [:create, :enable, :start]
        subscribes :restart, "template[#{source_file}]"
        only_if { File.exist?(source_file) }
      end
    end
    ## Configure nginx site to reverse proxy the traffic of 80 to application port
    nginx_site "site_#{app_name}" do
      template 'nginx_site.erb'
      cookbook 'nodeAuto'
      variables( 
        app: node['nodeAuto']['node_js']['app'][app_name]
        )
      action :enable
    end
  else
    Chef::Log.info("Application: #{app_name} configured not to Enable on this host #{node['name']}")
  end
end
