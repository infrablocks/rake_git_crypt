# frozen_string_literal: true

require_relative 'tasks/add_user'
require_relative 'tasks/add_users'
require_relative 'tasks/init'
require_relative 'tasks/install'
require_relative 'tasks/lock'
require_relative 'tasks/reinstall'
require_relative 'tasks/uninstall'
require_relative 'tasks/unlock'
require_relative 'tasks/unlock_with_encrypted_gpg_key'

module RakeGitCrypt
  module Tasks
  end
end
