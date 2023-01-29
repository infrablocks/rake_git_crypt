# frozen_string_literal: true

require 'rake_factory'
require 'ruby_git_crypt'

module RakeGitCrypt
  module Tasks
    class Unlock < RakeFactory::Task
      default_name :unlock
      default_description 'Unlock git-crypt.'

      parameter :key_paths

      action do
        puts('Unlocking git-crypt...')
        RubyGitCrypt.unlock(
          key_files: key_paths
        )
      end
    end
  end
end
