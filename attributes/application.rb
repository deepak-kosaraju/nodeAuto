default['nodeAuto']['node_js']['default_app_dir'] = '/opt/app'

default['nodeAuto']['node_js']['user'] = {
  name: 'node-web',
  id: 1024,
  shell: '/bin/bash', ## as app will be running as node-web user
}
default['nodeAuto']['node_js']['group'] = {
  name: 'node-web',
  id: 1024,
}

default['nodeAuto']['node_js']['bin'] = '/usr/bin/node'

default['nodeAuto']['node_js']['app'] = {
  profile: {
    enable: true,
    dir: '/opt/app/profile',
    dir_mode: 755,
    file_mode: 774,
    file: 'app.js',
    node_env: 'test',
    log_dir: '/opt/app/profile/var/log',
    log_file: '/opt/app/profile/var/log/app.log',
    port: 8080,
    host: '127.0.0.1',
    message: 'from profile application',
    systemd: {
      Unit: {
        Description: 'Simple Node App of nodeAuto Hello World!',
        After: 'network-online.target',
        Wants: 'network-online.target',
      },
      Service: {
        ExecStart: node['nodeAuto']['node_js']['bin'] + ' /opt/app/profile/app.js',
        ExecStop: '/bin/kill $MAINPID',
        KillMode: 'process',
        Restart: 'on-failure',
        ExecReload: '/bin/kill -HUP $MAINPID',
      },
      Install: {
        WantedBy: 'multi-user.target',
      }
    }
  },
  user: {
    enable: false,
    systemd: {
      Service: {
        ExecStart: node['nodeAuto']['node_js']['bin'] + ' /opt/app/user/app.js',
      }
    }
  }
}
