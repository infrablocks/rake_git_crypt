# frozen_string_literal: true

require 'spec_helper'
require 'open4'

describe RakeGitCrypt::Tasks::Lock do
  include_context 'rake'

  def define_task(opts = {}, &block)
    opts = { namespace: :git_crypt }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a lock task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:lock'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:lock'].full_comment)
      .to(eq('Lock git-crypt.'))
  end

  it 'allows multiple lock tasks to be declared' do
    define_task(namespace: :git_crypt1)
    define_task(namespace: :git_crypt2)

    expect(Rake.application).to(have_task_defined('git_crypt1:lock'))
    expect(Rake.application).to(have_task_defined('git_crypt2:lock'))
  end

  describe 'by default' do
    it 'locks git-crypt for the repository' do
      define_task

      stub_output
      stub_git_crypt_lock

      Rake::Task['git_crypt:lock'].invoke

      expect(RubyGitCrypt).to(have_received(:lock))
    end

    it 'does not pass a key name by default' do
      define_task

      stub_output
      stub_git_crypt_lock

      Rake::Task['git_crypt:lock'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:lock)
              .with(hash_including(key_name: nil)))
    end

    it 'passes the specified key name when provided' do
      define_task(key_name: 'supersecret')

      stub_output
      stub_git_crypt_lock

      Rake::Task['git_crypt:lock'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:lock)
              .with(hash_including(key_name: 'supersecret')))
    end

    it 'does not force lock by default' do
      define_task

      stub_output
      stub_git_crypt_lock

      Rake::Task['git_crypt:lock'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:lock)
              .with(hash_including(force: false)))
    end

    it 'passes the specified value for force when provided' do
      define_task(force: true)

      stub_output
      stub_git_crypt_lock

      Rake::Task['git_crypt:lock'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:lock)
              .with(hash_including(force: true)))
    end

    it 'does not lock all keys by default' do
      define_task

      stub_output
      stub_git_crypt_lock

      Rake::Task['git_crypt:lock'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:lock)
              .with(hash_including(all: false)))
    end

    it 'passes the specified value for all when provided' do
      define_task(all: true)

      stub_output
      stub_git_crypt_lock

      Rake::Task['git_crypt:lock'].invoke

      expect(RubyGitCrypt)
        .to(have_received(:lock)
              .with(hash_including(all: true)))
    end
  end

  describe 'when git-crypt already locked' do
    it 'does not raise an error' do
      define_task

      # rubocop:disable RSpec/VerifiedDoubleReference
      exitstatus = instance_double('exit status').as_null_object
      # rubocop:enable RSpec/VerifiedDoubleReference
      spawn_error = Open4::SpawnError.new('thing', exitstatus)

      stub_output

      allow(RubyGitCrypt)
        .to(receive(:lock)
              .and_raise(spawn_error))

      expect { Rake::Task['git_crypt:lock'].invoke }
        .not_to(raise_error(Exception))
    end
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_chdir
    allow(Dir).to(receive(:chdir).and_yield)
  end

  def stub_git_crypt_lock
    allow(RubyGitCrypt).to(receive(:lock))
  end
end
