# frozen_string_literal: true

require 'rake_factory'
require 'ruby_git_crypt'

module RakeGitCrypt
  module Tasks
    class Lock < RakeFactory::Task
      default_name :lock
      default_description 'Lock git-crypt.'

      parameter :key_name
      parameter :force, default: false
      parameter :all, default: false

      action do
        puts('Locking git-crypt...')
        RubyGitCrypt.lock(
          key_name: key_name,
          force: force,
          all: all
        )
      end
    end
  end
end
