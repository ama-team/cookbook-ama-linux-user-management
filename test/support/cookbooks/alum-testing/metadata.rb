# frozen_string_literal: true

require 'chef'

parent_cookbook_path = (0..3).reduce(__dir__) do |carrier|
  File.dirname(carrier)
end
parent_cookbook_metadata_path = File.join(parent_cookbook_path, 'metadata.rb')
parent_metadata = Chef::Cookbook::Metadata.new
parent_metadata.from_file(parent_cookbook_metadata_path)

name             'alum-testing'
maintainer       parent_metadata.maintainer
maintainer_email parent_metadata.maintainer_email
license          'All rights reserved'
description      'Provides testing support for ama-linux-user-management cookbook'
long_description 'Provides testing support for ama-linux-user-management cookbook'
version          parent_metadata.version

depends parent_metadata.name
