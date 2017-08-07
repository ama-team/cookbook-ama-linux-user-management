# frozen_string_literal: true

task :validate, [:platform] => %i[lint test]
