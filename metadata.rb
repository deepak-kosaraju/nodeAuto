name 'nodeAuto'
maintainer 'Deepak Kosaraju'
maintainer_email 'you@example.com'
license 'MIT'
description 'Installs/Configures nodejs Apps'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.1'

recipe 'nodeAuto', 'Based setup and including other recipes'
recipe 'nodeAuto::install_pkgs', 'Installs necessary packages for the requirements'
recipe 'nodeAuto::application', 'Setup and Configure Application'

depends 'nodejs', '~> 5.0'
depends 'nginx', '~> 8.1'
depends 'iptables', '~> 4.3'

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'

source_url 'https://github.com/gdv-deepakk/nodeAuto'
issues_url 'https://github.com/gdv-deepakk/nodeAuto/issues'
chef_version '>= 14.0' if respond_to?(:chef_version)