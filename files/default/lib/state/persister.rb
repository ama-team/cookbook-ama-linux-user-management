# frozen_string_literal: true

require 'ama-entity-mapper'

require_relative '../model/account'
require_relative '../model/group'
require_relative '../model/state'

module AMA
  module Chef
    module User
      module State
        # Saves data as node attributes
        class Persister
          attr_reader :node

          # @param [Chef::Node] node
          def initialize(node)
            @node = node
          end

          def retrieve(context_name)
            data = fetch(context_name) || {}
            Entity::Mapper.map(data, AMA::Chef::User::Model::State)
          end

          def persist(context_name, state)
            save([context_name], Entity::Mapper.normalize(state))
          end

          private

          def save(path, data)
            data = data.normalize if data.respond_to? :normalize
            write_handle(*path[0..-2])[path[-1]] = data
          end

          def fetch(*path)
            read_handle(*path)
          end

          def delete(*path)
            return if path.empty?
            path = [path] if path.is_a?(String)
            return if read_handle(path).nil?
            write_handle(path[0..-2]).delete(path[-1])
          end

          def expand_path(*path)
            %w[ama user state].push(*path)
          end

          def read_handle(*path)
            expand_path(*path).reduce(node) do |cursor, segment|
              cursor && cursor.key?(segment) ? cursor[segment] : nil
            end
          end

          def write_handle(*path)
            expand_path(*path).reduce(node.normal) do |cursor, segment|
              cursor[segment] = {} unless cursor.key?(segment)
              cursor[segment]
            end
          end
        end
      end
    end
  end
end
