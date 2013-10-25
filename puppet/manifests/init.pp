Exec { path => '/bin:/usr/bin:/usr/local/bin:/usr/sbin:/sbin' }

# Make sure apt-get is up-to-date before we do anything else
stage { 'updates': before => Stage['main'] }
class { 'updates': stage => updates }
class updates {
	exec { 'apt-get update':
		command => 'apt-get update --quiet --yes',
		timeout => 0
	}
}

import 'sections/*'

# Additional packages
package { 'postfix': ensure => present }
service { 'postfix': ensure => running }

# Set vip.dev in hosts file:
exec { 'setup hosts':
	command => 'sudo printf "\n# VIP Quickstart\n127.0.0.1 vip.dev\n" | sudo tee -a /etc/hosts',
	unless => 'cat /etc/hosts | grep vip.dev'
}

# Setup bash aliases
file { '/home/vagrant/.bash_aliases':
   ensure => 'link',
   target => '/vagrant/bin/dotfiles/quickstart_aliases',
}


# Configure postfix
exec { 'configure postfix hostname':
	command => 'sed -i "s/precise32/vip.dev/g" /etc/postfix/main.cf',
	onlyif => 'cat /etc/postfix/main.cf | grep "precise32"',
	user => root,
	notify => Service['postfix']
}
