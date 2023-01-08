# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::Init do
  include_context 'rake'

  def define_task(opts = {}, &block)
    opts = { namespace: :git_crypt }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds an init task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:init'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:init'].full_comment)
      .to(eq('Initialise git-crypt.'))
  end

  it 'allows multiple init tasks to be declared' do
    define_task(namespace: :git_crypt1)
    define_task(namespace: :git_crypt2)

    expect(Rake.application).to(have_task_defined('git_crypt1:init'))
    expect(Rake.application).to(have_task_defined('git_crypt2:init'))
  end

  it 'inits git-crypt for the repository' do
    define_task

    stub_output
    stub_git_crypt_init

    Rake::Task['git_crypt:init'].invoke

    expect(RubyGitCrypt).to(have_received(:init))
  end

  it 'does not pass a key name by default' do
    define_task

    stub_output
    stub_git_crypt_init

    Rake::Task['git_crypt:init'].invoke

    expect(RubyGitCrypt)
      .to(have_received(:init)
            .with(hash_including(key_name: nil)))
  end

  it 'does pass the specified key name when provided' do
    define_task(key_name: 'supersecret')

    stub_output
    stub_git_crypt_init

    Rake::Task['git_crypt:init'].invoke

    expect(RubyGitCrypt)
      .to(have_received(:init)
            .with(hash_including(key_name: 'supersecret')))
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

  def stub_git_crypt_init
    allow(RubyGitCrypt).to(receive(:init))
  end
end
