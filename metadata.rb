# frozen_string_literal: true

name 'ama-linux-user-management'
maintainer 'AMA Team'
maintainer_email 'ops@amagroup.ru'
source_url 'https://github.com/ama-team/cookbook-linux-user-management'
issues_url 'https://github.com/ama-team/cookbook-linux-user-management/issues'
license 'MIT'
description 'Installs/Configures ama-linux-user-management'
long_description 'Installs/Configures ama-linux-user-management'
chef_version '>= 12', '< 14'
version '0.1.0'

depends 'ssh_authorized_keys', '~> 0.3.0'
depends 'sudo', '~> 3.5.0'
depends 'ssh', '~> 0.10.22'
depends 'ama-ssh-private-keys', '~> 0.2.0'

supports 'debian', '>= 7.3'
supports 'ubuntu', '>= 14.04'
