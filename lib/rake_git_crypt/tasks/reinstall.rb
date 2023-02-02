# frozen_string_literal: true

require 'rake_factory'

require_relative '../mixins/support'

module RakeGitCrypt
  module Tasks
    class Reinstall < RakeFactory::Task
      include Mixins::Support

      default_name :reinstall
      default_description 'Reinstall git-crypt.'

      parameter :uninstall_task_name, default: :uninstall
      parameter :install_task_names, default: [:install]

      action do |task, args|
        puts('Reinstalling git-crypt...')
        validate(task)
        uninstall_git_crypt(task, args)
        install_git_crypt(task, args)
      end

      private

      def validate(task)
        [uninstall_task_name, *install_task_names].each do |name|
          raise_task_undefined(name) unless task_defined?(task, name)
        end
      end

      def uninstall_git_crypt(task, args)
        invoke_task_with_name(task, uninstall_task_name, args)
      end

      def install_git_crypt(task, args)
        install_task_names.each do |install_task_name|
          invoke_task_with_name(task, install_task_name, args)
        end
      end
    end
  end
end
