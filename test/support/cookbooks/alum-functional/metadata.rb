# frozen_string_literal: true

require 'chef'

parent_cookbook_path = (0..3).reduce(__dir__) do |carrier|
  File.dirname(carrier)
end
parent_cookbook_metadata_path = File.join(parent_cookbook_path, 'metadata.rb')
parent_metadata = Chef::Cookbook::Metadata.new
parent_metadata.from_file(parent_cookbook_metadata_path)

name             'alum-functional'
maintainer       parent_metadata.maintainer
maintainer_email parent_metadata.maintainer_email
license          'All rights reserved'
description      'Installs/Configures alum-functional'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          parent_metadata.version

depends parent_metadata.name
