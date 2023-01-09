# frozen_string_literal: true

require 'rake_factory'
require 'ruby_git_crypt'
require 'ruby_gpg2'

require_relative '../home'

module RakeGitCrypt
  module Tasks
    class AddUser < RakeFactory::Task
      default_name :add_user
      default_description 'Add user to git-crypt.'

      parameter :key_name

      parameter :commit, default: false
      parameter :trusted, default: false

      parameter :gpg_user_id
      parameter :gpg_user_key_path

      parameter :gpg_home_directory
      parameter :gpg_work_directory, default: '/tmp'

      action do
        validate

        if gpg_user_id
          log_adding_by_id
          add_gpg_user(gpg_home_directory, gpg_user_id)
          log_done
        end

        if gpg_user_key_path
          log_adding_by_key_path
          with_gpg_home_directory do |home_directory|
            result = import_key(home_directory)
            key_fingerprint = lookup_key_fingerprint(result)
            add_gpg_user(home_directory, key_fingerprint)
          end
          log_done
        end
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

      def add_gpg_user(gpg_home_directory, gpg_user_id)
        RubyGitCrypt.add_gpg_user(
          {
            gpg_user_id: gpg_user_id,
            key_name: key_name,
            no_commit: !commit,
            trusted: trusted
          },
          { environment: git_crypt_environment(gpg_home_directory) }
        )
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
