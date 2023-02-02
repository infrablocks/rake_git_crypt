# frozen_string_literal: true

require 'rake_factory'
require 'ruby_git_crypt'

require_relative '../mixins/support'

module RakeGitCrypt
  module Tasks
    class Uninstall < RakeFactory::Task
      include Mixins::Support

      default_name :uninstall
      default_description 'Uninstall git-crypt.'

      parameter(:commit_message_template,
                default: 'Uninstalling git-crypt.')

      parameter(:lock_task_name, default: :lock)
      parameter(:destroy_secrets_task_name)
      parameter(:commit_task_name)

      action do |task, args|
        puts('Uninstalling git-crypt...')
        lock_git_crypt(task, args)
        delete_git_crypt_directories
        maybe_delete_secrets(task, args)
        maybe_commit(task, args)
      end

      private

      def lock_git_crypt(task, args)
        invoke_and_reenable_task_with_name(task, lock_task_name, args)
      end

      def delete_git_crypt_directories
        FileUtils.rm_rf('.git-crypt')
        FileUtils.rm_rf('.git/git-crypt')
      end

      def maybe_delete_secrets(task, args)
        return unless destroy_secrets_task_name

        invoke_and_reenable_task_with_name(task, destroy_secrets_task_name, args)
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
