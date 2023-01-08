# frozen_string_literal: true

require 'rake_factory'
require 'ruby_git_crypt'
require 'ruby_gpg2'

module RakeGitCrypt
  module Tasks
    class AddUser < RakeFactory::Task
      default_name :add_user
      default_description 'Add user to git-crypt.'

      parameter :key_name

      parameter :commit, default: false

      parameter :gpg_user_id
      parameter :gpg_user_key_path

      parameter :gpg_home_directory

      action do
        validate

        if gpg_user_id
          log_adding_by_id
          add_gpg_user(gpg_user_id)
          log_done
        end

        if gpg_user_key_path
          log_adding_by_key_path
          result = import_key
          key_fingerprint = lookup_key_fingerprint(result)
          add_gpg_user(key_fingerprint)
          log_done
        end
      end

      private

      def validate
        return if gpg_user_id || gpg_user_key_path

        raise RakeFactory::RequiredParameterUnset,
              'One of gpg_user_id or gpg_user_key_path must be provided ' \
              'but neither was.'
      end

      def import_key
        RubyGPG2.import(
          key_file_paths: [gpg_user_key_path],
          with_status: true
        )
      end

      def lookup_key_fingerprint(result)
        result.status.filter_by_type(:import_ok)
              .first_line.key_fingerprint
      end

      def add_gpg_user(gpg_user_id)
        RubyGitCrypt.add_gpg_user(
          {
            key_name: key_name,
            gpg_user_id: gpg_user_id,
            no_commit: !commit
          },
          gpg_home_directory ? { GNUPGHOME: gpg_home_directory } : {}
        )
      end

      def log_adding_by_id
        $stdout.puts(
          "Adding GPG user with ID: '#{gpg_user_id}' to git-crypt..."
        )
      end

      def log_adding_by_key_path
        puts(
          "Adding GPG user with key at: '#{gpg_user_key_path}' to git-crypt..."
        )
      end

      def log_done
        $stdout.puts('Done.')
      end
    end
  end
end
