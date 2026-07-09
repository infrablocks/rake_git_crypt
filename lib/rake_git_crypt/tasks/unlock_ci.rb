# frozen_string_literal: true

require 'lino'
require 'rake_factory'
require 'ruby_git_crypt'
require 'ruby_gpg2'
require 'tmpdir'

module RakeGitCrypt
  module Tasks
    class UnlockCI < RakeFactory::Task
      default_name :unlock_ci
      default_description 'Unlock git-crypt using an encrypted CI GPG key.'

      parameter :encrypted_key_path, default: '.github/gpg.private.enc'
      parameter :passphrase_env_var_name, default: 'ENCRYPTION_PASSPHRASE'
      parameter :gpg_work_directory, default: '/tmp'

      action do
        ensure_passphrase_present
        ensure_encrypted_key_present

        puts('Unlocking git-crypt using encrypted CI GPG key...')
        with_decrypted_key do |decrypted_key_path|
          import_key(decrypted_key_path)
        end
        unlock
        puts('Done.')
      end

      private

      def ensure_passphrase_present
        passphrase = ENV.fetch(passphrase_env_var_name, nil)
        return unless passphrase.nil? || passphrase.empty?

        raise(RakeFactory::RequiredParameterUnset, passphrase_missing_message)
      end

      def ensure_encrypted_key_present
        return if File.file?(encrypted_key_path)

        raise(encrypted_key_missing_message)
      end

      def with_decrypted_key
        Dir.mktmpdir('git-crypt-ci', gpg_work_directory) do |directory|
          decrypted_key_path = File.join(directory, 'gpg.private')
          decrypt_key(decrypted_key_path)
          yield decrypted_key_path
        end
      end

      def decrypt_key(decrypted_key_path)
        openssl_command(decrypted_key_path).build.execute
      end

      def openssl_command(decrypted_key_path)
        Lino
          .builder_for_command('openssl')
          .with_options_after_subcommands
          .with_subcommand('aes-256-cbc')
          .with_flag('-d')
          .with_option('-md', 'sha1')
          .with_option('-in', encrypted_key_path)
          .with_option('-out', decrypted_key_path)
          .with_option('-pass', "env:#{passphrase_env_var_name}")
      end

      def import_key(decrypted_key_path)
        RubyGPG2.import(
          key_file_paths: [decrypted_key_path],
          work_directory: gpg_work_directory
        )
      end

      def unlock
        RubyGitCrypt.unlock
      end

      def passphrase_missing_message
        'No passphrase found in environment variable ' \
          "'#{passphrase_env_var_name}'. This passphrase decrypts the CI " \
          'GPG private key and is stored as the ' \
          "'#{passphrase_env_var_name}' secret in the repository's GitHub " \
          'Actions and Dependabot secrets stores (Settings > Secrets and ' \
          'variables). Expose it to this step, for example with:' \
          "\n  env:\n    #{passphrase_env_var_name}: " \
          "${{ secrets.#{passphrase_env_var_name} }}\n" \
          'For Dependabot-triggered runs the secret must also be mirrored ' \
          'into the Dependabot secrets store.'
      end

      def encrypted_key_missing_message
        'Encrypted CI GPG private key not found at ' \
          "'#{encrypted_key_path}'. Set the encrypted_key_path parameter " \
          'to the location of the OpenSSL-encrypted CI GPG private key ' \
          '(repositories part-way through migration may still hold it at ' \
          "'.circleci/gpg.private.enc')."
      end
    end
  end
end
