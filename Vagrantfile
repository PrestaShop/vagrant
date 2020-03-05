# -*- mode: ruby -*-
require 'shellwords'

Vagrant.configure('2') do |config|
  config.vm.box = 'debian/buster64'

  config.vm.hostname = 'prestashop'

  config.vm.network 'public_network'
  config.vm.network 'private_network', ip: '192.168.42.42'
  config.vm.provision :file, source: './files/phpmyadmin.conf', destination: '/tmp/phpmyadmin.conf'
  args = [
    Shellwords.escape(ENV['PHP_VERSION']),
    Shellwords.escape(ENV['PR']),
    Shellwords.escape(ENV['BRANCH'])
  ]
  config.vm.provision :shell, path: 'script.sh', args: args.join(' ')

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider 'virtualbox' do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    # Customize the amount of memory on the VM:
    vb.memory = '2048'
  end
end
