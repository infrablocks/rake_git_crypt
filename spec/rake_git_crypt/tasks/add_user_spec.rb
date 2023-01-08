# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::AddUser do
  include_context 'rake'

  def define_task(opts = {}, &block)
    opts = { namespace: :git_crypt }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

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

    it 'does not commit by default' do
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
        commit: true
      )

      stub_output
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(no_commit: false), anything))
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
              .with(anything, hash_including(GNUPGHOME: 'some/directory')))
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

    it 'adds a GPG user to git-crypt' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user))
    end

    it 'uses the ID of the imported GPG key to add the GPG user' do
      key_id = 'A65C6366D55F0BA7719EE38F582D74F22F5601F8'

      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
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
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(key_name: 'supersecret'), anything))
    end

    it 'does not commit by default' do
      define_task(gpg_user_key_path: 'path/to/gpg.public')

      stub_output
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
        commit: true
      )

      stub_output
      stub_gpg_import
      stub_git_crypt_add_gpg_user

      Rake::Task['git_crypt:add_user'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:add_gpg_user)
              .with(hash_including(no_commit: false), anything))
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

  def stub_git_crypt_add_gpg_user
    allow(RubyGitCrypt).to(receive(:add_gpg_user))
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
