# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::UnlockCI do
  include_context 'rake'

  def define_task(opts = {}, &)
    opts = { namespace: :git_crypt }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &)
    end
  end

  after do
    %w[ENCRYPTION_PASSPHRASE CUSTOM_PASSPHRASE].each { |name| ENV.delete(name) }
    Lino.reset!
  end

  it 'adds an unlock_ci task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:unlock_ci'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:unlock_ci'].full_comment)
      .to(eq('Unlock git-crypt using an encrypted CI GPG key.'))
  end

  it 'allows multiple unlock_ci tasks to be declared' do
    define_task(namespace: :git_crypt1)
    define_task(namespace: :git_crypt2)

    expect(Rake.application).to(have_task_defined('git_crypt1:unlock_ci'))
    expect(Rake.application).to(have_task_defined('git_crypt2:unlock_ci'))
  end

  it 'decrypts the key, imports it and unlocks git-crypt in that order' do
    define_task
    set_passphrase
    stub_encrypted_key
    stub_output
    executor = stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    expect(executor).to(have_received(:execute).ordered)
    expect(RubyGPG2).to(have_received(:import).ordered)
    expect(RubyGitCrypt).to(have_received(:unlock).ordered)
  end

  it 'decrypts the key with openssl aes-256-cbc using an sha1 digest' do
    define_task
    set_passphrase
    stub_encrypted_key
    stub_output
    executor = stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    expect(openssl_arguments(executor))
      .to(start_with(%w[openssl aes-256-cbc -d -md sha1]))
  end

  it 'reads the passphrase from the env var without placing it in argv' do
    define_task
    set_passphrase('super-secret-passphrase')
    stub_encrypted_key
    stub_output
    executor = stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    arguments = openssl_arguments(executor)
    expect(arguments).to(include('-pass', 'env:ENCRYPTION_PASSPHRASE'))
    expect(arguments).not_to(include('super-secret-passphrase'))
  end

  it 'decrypts the key at .github/gpg.private.enc by default' do
    define_task
    set_passphrase
    stub_encrypted_key
    stub_output
    executor = stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    expect(openssl_arguments(executor))
      .to(include('-in', '.github/gpg.private.enc'))
  end

  it 'decrypts the key at the specified path when provided' do
    define_task(encrypted_key_path: '.circleci/gpg.private.enc')
    set_passphrase
    stub_encrypted_key('.circleci/gpg.private.enc')
    stub_output
    executor = stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    expect(openssl_arguments(executor))
      .to(include('-in', '.circleci/gpg.private.enc'))
  end

  it 'reads the passphrase from ENCRYPTION_PASSPHRASE by default' do
    define_task
    set_passphrase
    stub_encrypted_key
    stub_output
    executor = stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    expect(openssl_arguments(executor))
      .to(include('-pass', 'env:ENCRYPTION_PASSPHRASE'))
  end

  it 'reads the passphrase from the specified env var when provided' do
    define_task(passphrase_env_var_name: 'CUSTOM_PASSPHRASE')
    set_passphrase(name: 'CUSTOM_PASSPHRASE')
    stub_encrypted_key
    stub_output
    executor = stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    expect(openssl_arguments(executor))
      .to(include('-pass', 'env:CUSTOM_PASSPHRASE'))
  end

  it 'imports the decrypted key into gpg' do
    define_task
    set_passphrase
    stub_encrypted_key
    stub_output
    stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    expect(RubyGPG2)
      .to(have_received(:import)
            .with(hash_including(
                    key_file_paths: [a_string_ending_with('gpg.private')]
                  )))
  end

  it 'unlocks git-crypt' do
    define_task
    set_passphrase
    stub_encrypted_key
    stub_output
    stub_openssl
    stub_gpg_import
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock_ci'].invoke

    expect(RubyGitCrypt).to(have_received(:unlock))
  end

  it 'raises a clear error when the passphrase env var is absent' do
    define_task
    ENV.delete('ENCRYPTION_PASSPHRASE')
    stub_encrypted_key
    stub_output

    expect { Rake::Task['git_crypt:unlock_ci'].invoke }
      .to(raise_error(
            RakeFactory::RequiredParameterUnset,
            /ENCRYPTION_PASSPHRASE.*Dependabot/m
          ))
  end

  it 'raises a clear error when the passphrase env var is empty' do
    define_task
    set_passphrase('')
    stub_encrypted_key
    stub_output

    expect { Rake::Task['git_crypt:unlock_ci'].invoke }
      .to(raise_error(
            RakeFactory::RequiredParameterUnset,
            /ENCRYPTION_PASSPHRASE/
          ))
  end

  it 'raises a clear error naming the path when the key file is missing' do
    define_task
    set_passphrase
    allow(File).to(receive(:file?).and_call_original)
    allow(File)
      .to(receive(:file?).with('.github/gpg.private.enc').and_return(false))
    stub_output

    expect { Rake::Task['git_crypt:unlock_ci'].invoke }
      .to(raise_error(%r{\.github/gpg\.private\.enc}))
  end

  def set_passphrase(value = 'the-passphrase', name: 'ENCRYPTION_PASSPHRASE')
    ENV[name] = value
  end

  def stub_encrypted_key(path = '.github/gpg.private.enc')
    allow(File).to(receive(:file?).and_call_original)
    allow(File).to(receive(:file?).with(path).and_return(true))
  end

  def stub_openssl
    executor = Lino::Executors::Mock.new
    Lino.configure { |config| config.executor = executor }
    allow(executor).to(receive(:execute).and_call_original)
    executor
  end

  def openssl_arguments(executor)
    executor.executions.first.command_line.array
  end

  def stub_gpg_import
    allow(RubyGPG2).to(receive(:import))
  end

  def stub_git_crypt_unlock
    allow(RubyGitCrypt).to(receive(:unlock))
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end
end
