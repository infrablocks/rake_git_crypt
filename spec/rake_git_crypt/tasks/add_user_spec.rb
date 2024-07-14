# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::AddUser do
  include_context 'rake'

  # rubocop:disable Metrics/MethodLength
  def define_task(opts = {}, &)
    opts = {
      namespace: :git_crypt,
      additional_namespaced_tasks: %i[],
      additional_top_level_tasks: %i[]
    }.merge(opts)

    opts[:additional_top_level_tasks].each do |t|
      task t
    end

    namespace opts[:namespace] do
      opts[:additional_namespaced_tasks].each do |t|
        task t
      end

      subject.define(opts, &)
    end
  end
  # rubocop:enable Metrics/MethodLength

  it 'adds an add_user task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:add_user'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:add_user'].full_comment)
      .to(eq('Add user to git-crypt.'))
  end

  it 'allows multiple add_gpg_user tasks to be declared' do
    define_task(namespace: :git_crypt1)
    define_task(namespace: :git_crypt2)

    expect(Rake.application).to(have_task_defined('git_crypt1:add_user'))
    expect(Rake.application).to(have_task_defined('git_crypt2:add_user'))
  end

  it 'raises an error when neither gpg_user_id nor gpg_user_key_path ' \
     'provided' do
    define_task

    stub_output
    stub_git_crypt_add_gpg_user

    expect do
      Rake::Task['git_crypt:add_user'].invoke
    end.to(raise_error(RakeFactory::RequiredParameterUnset))
  end

  describe 'when gpg_user_id is provided' do
    it 'adds a GPG user to git-crypt' do
      define_task(gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82')

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user))
    end

    it 'uses the specified GPG user ID to add the GPG user' do
      define_task(gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82')

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(
                      gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82'
                    ),
                    anything))
    end

    it 'does not provide a key name by default' do
      define_task(gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82')

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(key_name: nil), anything))
    end

    it 'uses the specified key name when provided' do
      define_task(
        gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82',
        key_name: 'supersecret'
      )

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(key_name: 'supersecret'), anything))
    end

    it 'does not allow git-crypt to commit by default' do
      define_task(gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82')

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(no_commit: true), anything))
    end

    it 'uses the specified value for no_commit when provided' do
      define_task(
        gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82',
        key_name: 'supersecret',
        allow_git_crypt_commit: true
      )

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(no_commit: false), anything))
    end

    it 'does not trust keys by default' do
      define_task(gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82')

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(trusted: false), anything))
    end

    it 'uses the specified value for trusted when provided' do
      define_task(
        gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82',
        key_name: 'supersecret',
        allow_untrusted_keys: true
      )

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(trusted: true), anything))
    end

    it 'does not set a GPG home directory when adding the user to git-crypt' do
      define_task(gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82')

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(anything, hash_excluding('GNUPGHOME')))
    end

    it 'sets the specified GPG home directory when adding the user to ' \
       'git-crypt when provided' do
      define_task(
        gpg_user_id: '41D2606F66C3FF28874362B61A16916844CE9D82',
        gpg_home_directory: 'some/directory'
      )

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(anything,
                    hash_including(
                      environment: { GNUPGHOME: 'some/directory' }
                    )))
    end

    describe 'when commit_task_name provided and task is defined' do
      it 'commits with an appropriate message by default' do
        gpg_user_id = '41D2606F66C3FF28874362B61A16916844CE9D82'

        define_task(
          gpg_user_id:,
          commit_task_name: :'git:commit',
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(Rake::Task['git:commit'])
          .to(have_received(:invoke)
                .with("Adding git-crypt GPG user with ID: '#{gpg_user_id}'."))
      end

      it 're-enables the commit task' do
        gpg_user_id = '41D2606F66C3FF28874362B61A16916844CE9D82'

        define_task(
          gpg_user_id:,
          commit_task_name: :'git:commit',
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(Rake::Task['git:commit'])
          .to(have_received(:reenable))
      end

      it 'invokes and re-enables the commit task in the correct order' do
        gpg_user_id = '41D2606F66C3FF28874362B61A16916844CE9D82'

        define_task(
          gpg_user_id:,
          commit_task_name: :'git:commit',
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(Rake::Task['git:commit'])
          .to(have_received(:invoke).ordered)
        expect(Rake::Task['git:commit'])
          .to(have_received(:reenable).ordered)
      end

      it 'uses the specified commit message template when provided' do
        gpg_user_id = '41D2606F66C3FF28874362B61A16916844CE9D82'

        define_task(
          key_name: 'admin',
          gpg_user_id:,
          commit_task_name: :'git:commit',
          commit_message_template:
            "Adding user for key: '<%= @task.key_name %>'.",
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(Rake::Task['git:commit'])
          .to(have_received(:invoke)
                .with("Adding user for key: 'admin'."))
      end

      it 'calls commit after adding the GPG user' do
        gpg_user_id = '41D2606F66C3FF28874362B61A16916844CE9D82'

        define_task(
          gpg_user_id:,
          commit_task_name: :'git:commit',
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(RubyGitCrypt)
          .to(have_received(:add_gpg_user).ordered)
        expect(Rake::Task['git:commit'])
          .to(have_received(:invoke).ordered)
      end
    end

    describe 'when commit_task_name provided and task not defined' do
      it 'raises an error' do
        gpg_user_id = '41D2606F66C3FF28874362B61A16916844CE9D82'

        define_task(
          gpg_user_id:,
          commit_task_name: :'git:commit'
        )

        stub_output
        stub_git_crypt_add_gpg_user

        expect { Rake::Task['git_crypt:add_user'].invoke }
          .to(raise_error(RakeFactory::DependencyTaskMissing))
      end
    end
  end

  describe 'when gpg_user_key_path is provided' do
    it 'imports the key' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGPG2)
        .to(have_received(:import)
              .with(hash_including(
                      key_file_paths: ['path/to/gpg.public'],
                      with_status: true
                    )))
    end

    it 'uses a temporary home directory by default when importing the key' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_dir_mktmpdir(temporary_directory: '/tmp/home-12345678')
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGPG2)
        .to(have_received(:import)
              .with(hash_including(
                      home_directory: '/tmp/home-12345678'
                    )))
    end

    it 'uses the specified home directory when provided when importing ' \
       'the key' do
      define_task(
        gpg_user_key_path: 'path/to/gpg.public',
        gpg_home_directory: 'nested/home/directory'
      )

      stub_output
      stub_file_utils_mkdir_p
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGPG2)
        .to(have_received(:import)
              .with(hash_including(
                      home_directory: 'nested/home/directory'
                    )))
    end

    it 'ensures the specified home directory exists when provided' do
      define_task(
        gpg_user_key_path: 'path/to/gpg.public',
        gpg_home_directory: 'nested/home/directory'
      )

      stub_output
      stub_file_utils_mkdir_p
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(FileUtils)
        .to(have_received(:mkdir_p)
              .with('nested/home/directory'))
    end

    it 'uses a work directory of /tmp by default when importing the key' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_dir_mktmpdir(work_directory: '/tmp')
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGPG2)
        .to(have_received(:import)
              .with(hash_including(
                      work_directory: '/tmp'
                    )))
    end

    it 'uses the specified work directory when provided when importing ' \
       'the key' do
      define_task(
        gpg_user_key_path: 'path/to/gpg.public',
        gpg_work_directory: 'nested/work/directory'
      )

      stub_output
      stub_dir_mktmpdir(work_directory: 'nested/work/directory')
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGPG2)
        .to(have_received(:import)
              .with(hash_including(
                      work_directory: 'nested/work/directory'
                    )))
    end

    it 'adds a GPG user to git-crypt' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_dir_mktmpdir
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user))
    end

    it 'uses a temporary home directory by default when adding the GPG user' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_dir_mktmpdir(temporary_directory: '/tmp/home-12345678')
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(
                anything,
                a_hash_including(
                  environment: { GNUPGHOME: '/tmp/home-12345678' }
                )
              ))
    end

    it 'implicitly trusts the key when using a temporary home directory ' \
       'when adding the GPG user' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_dir_mktmpdir
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(
                a_hash_including(trusted: true),
                anything
              ))
    end

    it 'uses the specified home directory when provided when adding the ' \
       'GPG user' do
      define_task(
        gpg_user_key_path: 'path/to/gpg.public',
        gpg_home_directory: 'nested/home/directory'
      )

      stub_output
      stub_file_utils_mkdir_p
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(
                anything,
                a_hash_including(
                  environment: { GNUPGHOME: 'nested/home/directory' }
                )
              ))
    end

    it 'uses the ID of the imported GPG key to add the GPG user' do
      key_id = 'A65C6366D55F0BA7719EE38F582D74F22F5601F8'

      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_dir_mktmpdir
      stub_gpg_import(import_ok_result(key_id))
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(gpg_user_id: key_id), anything))
    end

    it 'does not provide a key name by default' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_dir_mktmpdir
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(key_name: nil), anything))
    end

    it 'uses the specified key name when provided' do
      define_task(
        gpg_user_key_path: 'path/to/gpg.public',
        key_name: 'supersecret'
      )

      stub_output
      stub_dir_mktmpdir
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(key_name: 'supersecret'), anything))
    end

    it 'does not allow git-crypt to commit by default' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_dir_mktmpdir
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(no_commit: true), anything))
    end

    it 'uses the specified value for no_commit when provided' do
      define_task(
        gpg_user_key_path: 'path/to/gpg.public',
        key_name: 'supersecret',
        allow_git_crypt_commit: true
      )

      stub_output
      stub_dir_mktmpdir
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(no_commit: false), anything))
    end

    it 'does not trust the key when using a specified home directory' do
      define_task(
        gpg_user_key_path: 'path/to/gpg.public',
        gpg_home_directory: 'nested/home/directory'
      )

      stub_output
      stub_file_utils_mkdir_p
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(trusted: false), anything))
    end

    it 'uses the specified value for trusted when using a specified ' \
       'home directory' do
      define_task(
        gpg_user_key_path: 'path/to/gpg.public',
        gpg_home_directory: 'nested/home/directory',
        allow_untrusted_keys: true
      )

      stub_output
      stub_file_utils_mkdir_p
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(trusted: true), anything))
    end

    describe 'when commit_task_name provided and task is defined' do
      it 'commits with an appropriate message by default' do
        gpg_user_key_path = 'path/to/gpg.public'

        define_task(
          gpg_user_key_path:,
          commit_task_name: :'git:commit',
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_gpg_import
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(Rake::Task['git:commit'])
          .to(have_received(:invoke)
                .with('Adding git-crypt GPG user with key path: ' \
                      "'#{gpg_user_key_path}'."))
      end

      it 're-enables the commit task' do
        gpg_user_key_path = 'path/to/gpg.public'

        define_task(
          gpg_user_key_path:,
          commit_task_name: :'git:commit',
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_gpg_import
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(Rake::Task['git:commit'])
          .to(have_received(:reenable))
      end

      it 'invokes and re-enables the commit task in the correct order' do
        gpg_user_key_path = 'path/to/gpg.public'

        define_task(
          gpg_user_key_path:,
          commit_task_name: :'git:commit',
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_gpg_import
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(Rake::Task['git:commit'])
          .to(have_received(:invoke).ordered)
        expect(Rake::Task['git:commit'])
          .to(have_received(:reenable).ordered)
      end

      it 'uses the specified commit message template when provided' do
        gpg_user_key_path = 'path/to/gpg.public'

        define_task(
          key_name: 'admin',
          gpg_user_key_path:,
          commit_task_name: :'git:commit',
          commit_message_template:
            "Adding user for key: '<%= @task.key_name %>'.",
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_gpg_import
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(Rake::Task['git:commit'])
          .to(have_received(:invoke)
                .with("Adding user for key: 'admin'."))
      end

      it 'calls commit after adding the GPG user' do
        gpg_user_key_path = 'path/to/gpg.public'

        define_task(
          gpg_user_key_path:,
          commit_task_name: :'git:commit',
          additional_top_level_tasks: %i[git:commit]
        )

        stub_output
        stub_gpg_import
        stub_git_crypt_add_gpg_user
        stub_task('git:commit')

        Rake::Task['git_crypt:add_user'].invoke

        expect(RubyGitCrypt)
          .to(have_received(:add_gpg_user).ordered)
        expect(Rake::Task['git:commit'])
          .to(have_received(:invoke).ordered)
      end
    end

    describe 'when commit_task_name provided and task not defined' do
      it 'raises an error' do
        gpg_user_key_path = 'path/to/gpg.public'

        define_task(
          gpg_user_key_path:,
          commit_task_name: :'git:commit'
        )

        stub_output
        stub_gpg_import
        stub_git_crypt_add_gpg_user

        expect { Rake::Task['git_crypt:add_user'].invoke }
          .to(raise_error(RakeFactory::DependencyTaskMissing))
      end
    end
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_gpg_import(result = nil)
    result ||= import_ok_result
    allow(RubyGPG2)
      .to(receive(:import)
            .and_return(result))
  end

  def stub_dir_mktmpdir(
    work_directory: '/tmp',
    prefix: 'home',
    temporary_directory: '/tmp/home-00000000'
  )
    allow(Dir)
      .to(receive(:mktmpdir)
            .with(prefix, work_directory)
            .and_yield(temporary_directory))
  end

  def stub_file_utils_mkdir_p
    allow(FileUtils).to(receive(:mkdir_p))
  end

  def stub_git_crypt_add_gpg_user
    allow(RubyGitCrypt).to(receive(:add_gpg_user))
  end

  def stub_task(task_name)
    allow(Rake::Task[task_name]).to(receive(:invoke))
    allow(Rake::Task[task_name]).to(receive(:reenable))
  end

  def import_ok_result(key_id = 'E0637AE8F9059A371245DB3844528004E095862C')
    result = RubyGPG2::Commands::Result.new
    result.status = import_ok_status(key_id)
    result
  end

  def import_ok_status(key_id = 'E0637AE8F9059A371245DB3844528004E095862C')
    RubyGPG2::StatusOutput.new(
      [
        RubyGPG2::StatusLine.parse(
          "[GNUPG:] IMPORT_OK 1 #{key_id}"
        )
      ]
    )
  end
end
