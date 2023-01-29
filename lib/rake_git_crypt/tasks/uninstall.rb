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

      parameter(:lock_task_name, default: :lock)
      parameter(:delete_secrets_task_name)

      action do |task, args|
        puts('Uninstalling git-crypt...')
        lock_git_crypt(task, args)
        delete_git_crypt_directories
        maybe_delete_secrets(task, args)
      end

      private

      def lock_git_crypt(task, args)
        invoke_task_with_name(task, lock_task_name, args)
      end

      def delete_git_crypt_directories
        FileUtils.rm_rf('.git-crypt')
        FileUtils.rm_rf('.git/git-crypt')
      end

      def maybe_delete_secrets(task, args)
        return unless delete_secrets_task_name

        unless delete_secrets_task_defined?(task)
          raise_delete_secrets_task_undefined
        end

        invoke_task_with_name(task, delete_secrets_task_name, args)
      end

      def delete_secrets_task_defined?(task)
        task_defined?(task, delete_secrets_task_name)
      end

      def raise_delete_secrets_task_undefined
        raise(
          RakeFactory::DependencyTaskMissing,
          'The task with name defined in delete_secrets_task_name does not ' \
          'exist.'
        )
      end
    end
  end
end
