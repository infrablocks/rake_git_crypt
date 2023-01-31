# frozen_string_literal: true

require 'rake_factory'
require 'ruby_git_crypt'

require_relative '../mixins/support'

module RakeGitCrypt
  module Tasks
    class Install < RakeFactory::Task
      include Mixins::Support

      default_name :install
      default_description 'Install git-crypt.'

      parameter(:init_task_name, default: :init)
      parameter(:add_users_task_name, default: :add_users)

      action do |task, args|
        puts('Installing git-crypt...')
        init_git_crypt(task, args)
        add_users_to_git_crypt(task, args)
      end

      private

      def init_git_crypt(task, args)
        invoke_task_with_name(task, init_task_name, args)
      end

      def add_users_to_git_crypt(task, args)
        invoke_task_with_name(task, add_users_task_name, args)
      end
    end
  end
end
