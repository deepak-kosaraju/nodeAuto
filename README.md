## nodeAuto
Table of Contents
=================

* [Get Started](#get-started)
  * [Design Principles](#design-principles)
  * [Supported Configuration Orchestrator](#supported-configuration-orchestrator)
  * [Application Attributes](#application-attributes)
  * [Converge using KitchenCI](#converge-using-kitchenci)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)

An application development team needs a new server 
configured to run their new internal application. 

I will use `Vagrant` and `Virtualbox` (or `Kitchen` and `Virtualbox`) 
to manage a local instance, and the `Vagrant` “provision” (or 
`kitchen converge`) functionality to configure the server. 

The application requires the following:

* Nginx as a reverse proxy
* NodeJS
* MemcacheD
* A simple MySQL server
* Host-based firewall configuration (such as iptables or netfilter) 
  so that the application is only accessible from the 10.0.0.0/8 subnet
  
For the scope of this practice, Nginx, MemcacheD, and MySQL will 
run on the same host as the application.

## Get Started

### Design Principles
- Solution should be implemented in a standard open-source tool chain 
using commonly available libraries and tools
- Aim to provide a simple but robust solution which others could 
easily use and extend

### Supported Chef Version
- \>= 14.0

### Application Attributes
_*For Sake of this nodeAuto I am using same cookbook to configure multiple apps, but its good practice to seaparete cookbook for individual apps*_
```ruby
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
```
### Converge using KitchenCI
```bash
 $ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1404  Vagrant  ChefZero     Busser    Ssh        <Not Created>  <None>
default-centos-71    Vagrant  ChefZero     Busser    Ssh        <Not Created>  <None>
user-ubuntu-1404     Vagrant  ChefZero     Busser    Ssh        <Not Created>  <None>
user-centos-71       Vagrant  ChefZero     Busser    Ssh        <Not Created>  <None>

$ kitchen converge <Instance Name>

$ while read name;do kitchen exec $name -c 'curl -L http://localhost';done< <(kitchen list -b)
-----> Execute command on default-ubuntu-1404.
       Hello World - from profile application running on host:default-ubuntu-1404 over port:8080
-----> Execute command on default-centos-71.
       Hello World - from profile application running on host:default-centos-71 over port:8080
-----> Execute command on user-ubuntu-1404.
       Hello World - from user application running on host:user-ubuntu-1404 over port:8090
-----> Execute command on user-centos-71.
       Hello World - from user application running on host:user-centos-71 over port:8090
```

**Final Converge list**: `kitchen list -j`
```json
[
  {
    "instance": "default-ubuntu-1404",
    "driver": "Vagrant",
    "provisioner": "ChefZero",
    "verifier": "Busser",
    "transport": "Ssh",
    "last_action": "converge",
    "last_error": null
  },
  {
    "instance": "default-centos-71",
    "driver": "Vagrant",
    "provisioner": "ChefZero",
    "verifier": "Busser",
    "transport": "Ssh",
    "last_action": "converge",
    "last_error": null
  },
  {
    "instance": "user-ubuntu-1404",
    "driver": "Vagrant",
    "provisioner": "ChefZero",
    "verifier": "Busser",
    "transport": "Ssh",
    "last_action": "converge",
    "last_error": null
  },
  {
    "instance": "user-centos-71",
    "driver": "Vagrant",
    "provisioner": "ChefZero",
    "verifier": "Busser",
    "transport": "Ssh",
    "last_action": "converge",
    "last_error": null
  }
]
```