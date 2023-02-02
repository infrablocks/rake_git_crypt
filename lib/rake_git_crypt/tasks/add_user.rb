# frozen_string_literal: true

require 'rake_factory'
require 'ruby_git_crypt'
require 'ruby_gpg2'

require_relative '../home'
require_relative '../template'
require_relative '../mixins/support'

module RakeGitCrypt
  module Tasks
    class AddUser < RakeFactory::Task
      include Mixins::Support

      default_name :add_user
      default_description 'Add user to git-crypt.'

      parameter :key_name

      parameter :allow_git_crypt_commit, default: false
      parameter :allow_untrusted_keys, default: false

      parameter :gpg_user_id
      parameter :gpg_user_key_path

      parameter :gpg_home_directory
      parameter :gpg_work_directory, default: '/tmp'

      parameter :commit_message_template,
                default: 'Adding git-crypt GPG user with <%= @type %>: ' \
                         "'<%= @value %>'."

      parameter :commit_task_name

      action do |task, args|
        validate

        if gpg_user_id
          log_adding_by_id
          add_gpg_user(gpg_home_directory, gpg_user_id)
        elsif gpg_user_key_path
          log_adding_by_key_path
          with_gpg_home_directory do |home_directory|
            result = import_key(home_directory)
            key_fingerprint = lookup_key_fingerprint(result)
            add_gpg_user(home_directory, key_fingerprint,
                         auto_trust: gpg_home_directory.nil?)
          end
        end

        maybe_commit(task, args)
        log_done
      end

      private

      def with_gpg_home_directory(&block)
        Home.new(gpg_work_directory, gpg_home_directory || :temporary)
            .with_resolved_directory do |home_directory|
          block.call(home_directory)
        end
      end

      def validate
        return if gpg_user_id || gpg_user_key_path

        raise RakeFactory::RequiredParameterUnset,
              'One of gpg_user_id or gpg_user_key_path must be provided ' \
              'but neither was.'
      end

      def import_key(gpg_home_directory)
        RubyGPG2.import(
          key_file_paths: [gpg_user_key_path],
          work_directory: gpg_work_directory,
          home_directory: gpg_home_directory,
          with_status: true
        )
      end

      def lookup_key_fingerprint(result)
        result.status.filter_by_type(:import_ok)
              .first_line.key_fingerprint
      end

      def add_gpg_user(gpg_home_directory, gpg_user_id, auto_trust: false)
        RubyGitCrypt.add_gpg_user(
          {
            gpg_user_id: gpg_user_id,
            key_name: key_name,
            no_commit: !allow_git_crypt_commit,
            trusted: auto_trust || allow_untrusted_keys
          },
          { environment: git_crypt_environment(gpg_home_directory) }
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
                .render(type: gpg_user_id ? 'ID' : 'key path',
                        value: gpg_user_id || gpg_user_key_path,
                        task: task)
      end

      def git_crypt_environment(gpg_home_directory)
        gpg_home_directory ? { GNUPGHOME: gpg_home_directory } : {}
      end

      def log_adding_by_id
        $stdout.puts(
          "Adding GPG user with ID: '#{gpg_user_id}' to git-crypt..."
        )
      end

      def log_adding_by_key_path
        $stdout.puts(
          "Adding GPG user with key at: '#{gpg_user_key_path}' to git-crypt..."
        )
      end

      def log_done
        $stdout.puts('Done.')
      end
    end
  end
end
