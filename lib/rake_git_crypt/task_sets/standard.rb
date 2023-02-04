# frozen_string_literal: true

require 'rake_factory'

module RakeGitCrypt
  module TaskSets
    # rubocop:disable Metrics/ClassLength
    class Standard < RakeFactory::TaskSet
      prepend RakeFactory::Namespaceable

      parameter :key_name

      parameter :gpg_home_directory
      parameter :gpg_work_directory, default: '/tmp'

      parameter :gpg_user_ids, default: []
      parameter :gpg_user_key_paths, default: []

      parameter :allow_git_crypt_commit, default: false
      parameter :allow_untrusted_keys, default: false

      parameter :lock_when_unclean, default: false
      parameter :lock_all_keys, default: false

      parameter :unlock_key_paths

      parameter :install_commit_message_template,
                default: 'Installing git-crypt.'
      parameter :install_commit_task_name

      parameter :uninstall_commit_message_template,
                default: 'Uninstalling git-crypt.'
      parameter :uninstall_commit_task_name

      parameter :add_users_commit_message_template,
                default: 'Adding users to git-crypt.'
      parameter :add_users_commit_task_name

      parameter :add_user_by_id_commit_message_template,
                default: 'Adding git-crypt GPG user with <%= @type %>: ' \
                         "'<%= @value %>'."
      parameter :add_user_by_id_commit_task_name

      parameter :add_user_by_key_path_commit_message_template,
                default: 'Adding git-crypt GPG user with <%= @type %>: ' \
                         "'<%= @value %>'."
      parameter :add_user_by_key_path_commit_task_name

      parameter :provision_secrets_task_name
      parameter :destroy_secrets_task_name

      parameter :init_task_name, default: :init
      parameter :lock_task_name, default: :lock
      parameter :unlock_task_name, default: :unlock
      parameter :install_task_name, default: :install
      parameter :uninstall_task_name, default: :uninstall
      parameter :reinstall_task_name, default: :reinstall
      parameter :add_users_task_name, default: :add_users
      parameter :add_user_by_id_task_name,
                default: :add_user_by_id
      parameter :add_user_by_key_path_task_name,
                default: :add_user_by_key_path

      task(Tasks::Init,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.init_task_name
             end
           })
      task(Tasks::Lock,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.lock_task_name
             end,
             force: RakeFactory::DynamicValue.new do |ts|
               ts.lock_when_unclean
             end,
             all: RakeFactory::DynamicValue.new do |ts|
               ts.lock_all_keys
             end
           })
      task(Tasks::Unlock,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.unlock_task_name
             end,
             key_paths: RakeFactory::DynamicValue.new do |ts|
               ts.unlock_key_paths
             end
           })
      task(Tasks::Install,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.install_task_name
             end,
             commit_message_template: RakeFactory::DynamicValue.new do |ts|
               ts.install_commit_message_template
             end,
             commit_task_name: RakeFactory::DynamicValue.new do |ts|
               ts.install_commit_task_name
             end
           })
      task(Tasks::Uninstall,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.uninstall_task_name
             end,
             commit_message_template: RakeFactory::DynamicValue.new do |ts|
               ts.uninstall_commit_message_template
             end,
             commit_task_name: RakeFactory::DynamicValue.new do |ts|
               ts.uninstall_commit_task_name
             end
           })
      task(Tasks::Reinstall,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.reinstall_task_name
             end,
             install_task_names: RakeFactory::DynamicValue.new do |ts|
               [ts.install_task_name]
             end
           })
      task(Tasks::AddUsers,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.add_users_task_name
             end,
             commit_message_template: RakeFactory::DynamicValue.new do |ts|
               ts.add_users_commit_message_template
             end,
             commit_task_name: RakeFactory::DynamicValue.new do |ts|
               ts.add_users_commit_task_name
             end
           })
      task(Tasks::AddUser,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.add_user_by_id_task_name
             end,
             commit_message_template: RakeFactory::DynamicValue.new do |ts|
               ts.add_user_by_id_commit_message_template
             end,
             commit_task_name: RakeFactory::DynamicValue.new do |ts|
               ts.add_user_by_id_commit_task_name
             end,
             argument_names: [:gpg_user_id]
           }) do |_, t, args|
        t.gpg_user_id = args.gpg_user_id
      end
      task(Tasks::AddUser,
           {
             name: RakeFactory::DynamicValue.new do |ts|
               ts.add_user_by_key_path_task_name
             end,
             commit_message_template: RakeFactory::DynamicValue.new do |ts|
               ts.add_user_by_key_path_commit_message_template
             end,
             commit_task_name: RakeFactory::DynamicValue.new do |ts|
               ts.add_user_by_key_path_commit_task_name
             end,
             argument_names: [:gpg_user_key_path]
           }) do |_, t, args|
        t.gpg_user_key_path = args.gpg_user_key_path
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
