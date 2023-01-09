# frozen_string_literal: true

require 'rake_factory'

module RakeGitCrypt
  module Tasks
    class AddUsers < RakeFactory::Task
      default_name :add_users
      default_description 'Add users to git-crypt.'

      parameter :gpg_user_key_paths

      action do
        # no-op
      end
    end
  end
end
