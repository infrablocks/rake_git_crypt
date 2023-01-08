# frozen_string_literal: true

require 'rake_factory'
require 'ruby_git_crypt'

module RakeGitCrypt
  module Tasks
    class Init < RakeFactory::Task
      default_name :init
      default_description 'Initialise git-crypt.'

      parameter :key_name

      action do |task|
        puts('Initialising git-crypt...')
        RubyGitCrypt.init(
          key_name: task.key_name
        )
      end
    end
  end
end
