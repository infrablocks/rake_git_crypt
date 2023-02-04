# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::TaskSets::Standard do
  include_context 'rake'

  it 'adds all tasks in the provided namespace ' \
     'when supplied' do
    described_class.define(
      namespace: :git_crypt
    )

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[
              git_crypt:init
              git_crypt:lock
              git_crypt:unlock
              git_crypt:install
              git_crypt:uninstall
              git_crypt:reinstall
              git_crypt:add_user_by_id
              git_crypt:add_user_by_key_path
              git_crypt:add_users
            ]
          ))
  end

  it 'adds all tasks in the root namespace when none supplied' do
    described_class.define

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[
              init
              lock
              unlock
              install
              uninstall
              reinstall
              add_user_by_id
              add_user_by_key_path
              add_users
            ]
          ))
  end

  describe 'init task' do
    it 'uses a nil key name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:init']

      expect(rake_task.creator.key_name).to(be_nil)
    end

    it 'uses the provided key name when supplied' do
      namespace :git_crypt do
        described_class.define(
          key_name: 'admin'
        )
      end

      rake_task = Rake::Task['git_crypt:init']

      expect(rake_task.creator.key_name).to(eq('admin'))
    end

    it 'uses the provided init task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          init_task_name: :initialise
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:initialise'))
    end
  end

  describe 'lock task' do
    it 'uses a nil key name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:lock']

      expect(rake_task.creator.key_name).to(be_nil)
    end

    it 'uses the provided key name when supplied' do
      namespace :git_crypt do
        described_class.define(
          key_name: 'admin'
        )
      end

      rake_task = Rake::Task['git_crypt:lock']

      expect(rake_task.creator.key_name).to(eq('admin'))
    end

    it 'does not lock when unclean by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:lock']

      expect(rake_task.creator.force).to(be(false))
    end

    it 'locks when unclean when specified' do
      namespace :git_crypt do
        described_class.define(
          lock_when_unclean: true
        )
      end

      rake_task = Rake::Task['git_crypt:lock']

      expect(rake_task.creator.force).to(be(true))
    end

    it 'does not lock all keys by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:lock']

      expect(rake_task.creator.all).to(be(false))
    end

    it 'locks all keys when specified' do
      namespace :git_crypt do
        described_class.define(
          lock_all_keys: true
        )
      end

      rake_task = Rake::Task['git_crypt:lock']

      expect(rake_task.creator.all).to(be(true))
    end

    it 'uses the provided lock task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          lock_task_name: :encrypt
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:encrypt'))
    end
  end

  describe 'unlock task' do
    it 'uses no key paths by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:unlock']

      expect(rake_task.creator.key_paths).to(be_nil)
    end

    it 'uses the provided key paths when supplied' do
      namespace :git_crypt do
        described_class.define(
          unlock_key_paths: ['path/to/key']
        )
      end

      rake_task = Rake::Task['git_crypt:unlock']

      expect(rake_task.creator.key_paths).to(eq(['path/to/key']))
    end

    it 'uses the provided unlock task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          unlock_task_name: :decrypt
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:decrypt'))
    end
  end

  describe 'install task' do
    it 'uses an appropriate commit message template by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Installing git-crypt.'))
    end

    it 'uses the provided commit message template when supplied' do
      namespace :git_crypt do
        described_class.define(
          install_commit_message_template: 'Adding git-crypt and users.'
        )
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Adding git-crypt and users.'))
    end

    it 'uses a nil commit task name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.commit_task_name).to(be_nil)
    end

    it 'uses the provided commit task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          install_commit_task_name: :commit
        )
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.commit_task_name)
        .to(eq(:commit))
    end

    it 'uses an init task name of init by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.init_task_name)
        .to(eq(:init))
    end

    it 'uses the provided init task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          init_task_name: :initialise
        )
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.init_task_name)
        .to(eq(:initialise))
    end

    it 'uses an add users task name of add_users by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.add_users_task_name)
        .to(eq(:add_users))
    end

    it 'uses the provided add users task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_users_task_name: :add_admins
        )
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.add_users_task_name)
        .to(eq(:add_admins))
    end

    it 'uses a nil provision secrets task name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.provision_secrets_task_name).to(be_nil)
    end

    it 'uses the provided provision secrets task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          provision_secrets_task_name: :provision_secrets
        )
      end

      rake_task = Rake::Task['git_crypt:install']

      expect(rake_task.creator.provision_secrets_task_name)
        .to(eq(:provision_secrets))
    end

    it 'uses the provided install task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          install_task_name: :setup
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:setup'))
    end
  end

  describe 'uninstall task' do
    it 'uses an appropriate commit message template by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:uninstall']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Uninstalling git-crypt.'))
    end

    it 'uses the provided commit message template when supplied' do
      namespace :git_crypt do
        described_class.define(
          uninstall_commit_message_template: 'Removing git-crypt and secrets.'
        )
      end

      rake_task = Rake::Task['git_crypt:uninstall']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Removing git-crypt and secrets.'))
    end

    it 'uses a nil commit task name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:uninstall']

      expect(rake_task.creator.commit_task_name).to(be_nil)
    end

    it 'uses the provided commit task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          uninstall_commit_task_name: :commit
        )
      end

      rake_task = Rake::Task['git_crypt:uninstall']

      expect(rake_task.creator.commit_task_name)
        .to(eq(:commit))
    end

    it 'uses a lock task name of lock by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:uninstall']

      expect(rake_task.creator.lock_task_name)
        .to(eq(:lock))
    end

    it 'uses the provided lock task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          lock_task_name: :encrypt
        )
      end

      rake_task = Rake::Task['git_crypt:uninstall']

      expect(rake_task.creator.lock_task_name)
        .to(eq(:encrypt))
    end

    it 'uses a nil destroy secrets task name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:uninstall']

      expect(rake_task.creator.destroy_secrets_task_name).to(be_nil)
    end

    it 'uses the provided destroy secrets task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          destroy_secrets_task_name: :destroy_secrets
        )
      end

      rake_task = Rake::Task['git_crypt:uninstall']

      expect(rake_task.creator.destroy_secrets_task_name)
        .to(eq(:destroy_secrets))
    end

    it 'uses the provided uninstall task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          uninstall_task_name: :remove
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:remove'))
    end
  end

  describe 'reinstall task' do
    it 'uses an uninstall task name of uninstall by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:reinstall']

      expect(rake_task.creator.uninstall_task_name)
        .to(eq(:uninstall))
    end

    it 'uses the provided uninstall task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          uninstall_task_name: :remove
        )
      end

      rake_task = Rake::Task['git_crypt:reinstall']

      expect(rake_task.creator.uninstall_task_name)
        .to(eq(:remove))
    end

    it 'uses an install task name of install by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:reinstall']

      expect(rake_task.creator.install_task_names)
        .to(eq([:install]))
    end

    it 'uses the provided install task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          install_task_name: :setup
        )
      end

      rake_task = Rake::Task['git_crypt:reinstall']

      expect(rake_task.creator.install_task_names)
        .to(eq([:setup]))
    end

    it 'uses the provided reinstall task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          reinstall_task_name: :rotate
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:rotate'))
    end
  end

  describe 'add_users task' do
    it 'uses an appropriate commit message template by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Adding users to git-crypt.'))
    end

    it 'uses the provided commit message template when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_users_commit_message_template:
            'Adding authorised users to git-crypt.'
        )
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Adding authorised users to git-crypt.'))
    end

    it 'uses a nil commit task name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.commit_task_name).to(be_nil)
    end

    it 'uses the provided commit task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_users_commit_task_name: :commit
        )
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.commit_task_name)
        .to(eq(:commit))
    end

    it 'uses an empty list of GPG user IDs by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.gpg_user_ids)
        .to(eq([]))
    end

    it 'uses the provided GPG user IDs when specified' do
      namespace :git_crypt do
        described_class.define(
          gpg_user_ids: [
            '41D2606F66C3FF28874362B61A16916844CE9D82'
          ]
        )
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.gpg_user_ids)
        .to(eq([
                 '41D2606F66C3FF28874362B61A16916844CE9D82'
               ]))
    end

    it 'uses an empty list of GPG user key paths by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.gpg_user_key_paths)
        .to(eq([]))
    end

    it 'uses the provided GPG user key paths when specified' do
      stub_file('config/keys/key1')
      stub_file('config/keys/key2')

      namespace :git_crypt do
        described_class.define(
          gpg_user_key_paths: %w[
            config/keys/key1
            config/keys/key2
          ]
        )
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.gpg_user_key_paths)
        .to(eq(%w[
                 config/keys/key1
                 config/keys/key2
               ]))
    end

    it 'uses an add user by ID task name of add_user_by_id by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.add_user_by_id_task_name)
        .to(eq(:add_user_by_id))
    end

    it 'uses the provided add user by ID task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_user_by_id_task_name: :add_admin_by_id
        )
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.add_user_by_id_task_name)
        .to(eq(:add_admin_by_id))
    end

    it 'uses an add user by key path task name of add_user_by_key_path ' \
       'by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.add_user_by_key_path_task_name)
        .to(eq(:add_user_by_key_path))
    end

    it 'uses the provided add user by key path task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_user_by_key_path_task_name: :add_admin_by_key_path
        )
      end

      rake_task = Rake::Task['git_crypt:add_users']

      expect(rake_task.creator.add_user_by_key_path_task_name)
        .to(eq(:add_admin_by_key_path))
    end

    it 'uses the provided add users task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_users_task_name: :add_admins
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:add_admins'))
    end
  end

  describe 'add user by ID task' do
    it 'passes argument names including the gpg_user_id' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.argument_names).to(eq([:gpg_user_id]))
    end

    it 'does not allow git-crypt to commit by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.allow_git_crypt_commit).to(be(false))
    end

    it 'uses the provided value for allowing git-crypt to commit ' \
       'when specified' do
      namespace :git_crypt do
        described_class.define(
          allow_git_crypt_commit: true
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.allow_git_crypt_commit).to(be(true))
    end

    it 'does not allow untrusted keys by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.allow_untrusted_keys).to(be(false))
    end

    it 'uses the provided value for allowing untrusted keys ' \
       'when specified' do
      namespace :git_crypt do
        described_class.define(
          allow_untrusted_keys: true
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.allow_untrusted_keys).to(be(true))
    end

    it 'uses a nil GPG home directory by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.gpg_home_directory).to(be_nil)
    end

    it 'uses the provided GPG home directory when supplied' do
      namespace :git_crypt do
        described_class.define(
          gpg_home_directory: 'gpg-home'
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.gpg_home_directory)
        .to(eq('gpg-home'))
    end

    it 'uses /tmp as the GPG work directory by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.gpg_work_directory).to(eq('/tmp'))
    end

    it 'uses the provided GPG work directory when supplied' do
      namespace :git_crypt do
        described_class.define(
          gpg_work_directory: './tmp'
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.gpg_work_directory)
        .to(eq('./tmp'))
    end

    it 'uses an appropriate commit message template by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Adding git-crypt GPG user with <%= @type %>: ' \
               "'<%= @value %>'."))
    end

    it 'uses the provided commit message template when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_user_by_id_commit_message_template:
            'Adding user by ID to git-crypt.'
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Adding user by ID to git-crypt.'))
    end

    it 'uses a nil commit task name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.commit_task_name).to(be_nil)
    end

    it 'uses the provided commit task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_user_by_id_commit_task_name: :commit
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_id']

      expect(rake_task.creator.commit_task_name)
        .to(eq(:commit))
    end

    it 'uses the provided add user by ID task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_user_by_id_task_name: :add_admin_by_id
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:add_admin_by_id'))
    end
  end

  describe 'add user by key path task' do
    it 'passes argument names including the gpg_user_key_path' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.argument_names).to(eq([:gpg_user_key_path]))
    end

    it 'does not allow git-crypt to commit by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.allow_git_crypt_commit).to(be(false))
    end

    it 'uses the provided value for allowing git-crypt to commit ' \
       'when specified' do
      namespace :git_crypt do
        described_class.define(
          allow_git_crypt_commit: true
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.allow_git_crypt_commit).to(be(true))
    end

    it 'does not allow untrusted keys by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.allow_untrusted_keys).to(be(false))
    end

    it 'uses the provided value for allowing untrusted keys ' \
       'when specified' do
      namespace :git_crypt do
        described_class.define(
          allow_untrusted_keys: true
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.allow_untrusted_keys).to(be(true))
    end

    it 'uses a nil GPG home directory by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.gpg_home_directory).to(be_nil)
    end

    it 'uses the provided GPG home directory when supplied' do
      namespace :git_crypt do
        described_class.define(
          gpg_home_directory: 'gpg-home'
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.gpg_home_directory)
        .to(eq('gpg-home'))
    end

    it 'uses /tmp as the GPG work directory by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.gpg_work_directory).to(eq('/tmp'))
    end

    it 'uses the provided GPG work directory when supplied' do
      namespace :git_crypt do
        described_class.define(
          gpg_work_directory: './tmp'
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.gpg_work_directory)
        .to(eq('./tmp'))
    end

    it 'uses an appropriate commit message template by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Adding git-crypt GPG user with <%= @type %>: ' \
               "'<%= @value %>'."))
    end

    it 'uses the provided commit message template when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_user_by_key_path_commit_message_template:
            'Adding user by key path to git-crypt.'
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.commit_message_template)
        .to(eq('Adding user by key path to git-crypt.'))
    end

    it 'uses a nil commit task name by default' do
      namespace :git_crypt do
        described_class.define
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.commit_task_name).to(be_nil)
    end

    it 'uses the provided commit task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_user_by_key_path_commit_task_name: :commit
        )
      end

      rake_task = Rake::Task['git_crypt:add_user_by_key_path']

      expect(rake_task.creator.commit_task_name)
        .to(eq(:commit))
    end

    it 'uses the provided add user by key path task name when supplied' do
      namespace :git_crypt do
        described_class.define(
          add_user_by_key_path_task_name: :add_admin_by_key_path
        )
      end

      expect(Rake.application)
        .to(have_task_defined('git_crypt:add_admin_by_key_path'))
    end
  end

  def stub_file(path)
    allow(File).to(receive(:file?).with(path).and_return(true))
    allow(File).to(receive(:directory?).with(path).and_return(false))
  end
end
