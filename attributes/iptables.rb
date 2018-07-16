default['nodeAuto']['iptables']['rules']['input_allow'] = [
  '# Allow traffic over port 80 only from 10.0.0.0/8 subnet',
  '-A INPUT -p tcp -s 10.0.0.0/8 --dport 80 -j ACCEPT',
]
