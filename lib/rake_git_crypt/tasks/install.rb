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

      parameter(:commit_message_template,
                default: 'Installing git-crypt.')

      parameter(:init_task_name, default: :init)
      parameter(:add_users_task_name, default: :add_users)
      parameter(:provision_secrets_task_name)
      parameter(:commit_task_name)

      action do |task, args|
        puts('Installing git-crypt...')
        init_git_crypt(task, args)
        maybe_provision_secrets(task, args)
        add_users_to_git_crypt(task, args)
        maybe_commit(task, args)
      end

      private

      def init_git_crypt(task, args)
        invoke_and_reenable_task_with_name(task, init_task_name, args)
      end

      def add_users_to_git_crypt(task, args)
        invoke_and_reenable_task_with_name(task, add_users_task_name, args)
      end

      def maybe_provision_secrets(task, args)
        return unless provision_secrets_task_name

        invoke_and_reenable_task_with_name(
          task, provision_secrets_task_name, args
        )
      end

      def maybe_commit(task, args)
        return unless commit_task_name

        invoke_and_reenable_task_with_name(
          task, commit_task_name,
          [commit_message(task), *args]
        )
      end

      def commit_message(task)
        Template.new(commit_message_template)
                .render(task: task)
      end
    end
  end
end
