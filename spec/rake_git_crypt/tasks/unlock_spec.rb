# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::Unlock do
  include_context 'rake'

  def define_task(opts = {}, &)
    opts = { namespace: :git_crypt }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &)
    end
  end

  it 'adds an unlock task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:unlock'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:unlock'].full_comment)
      .to(eq('Unlock git-crypt.'))
  end

  it 'allows multiple unlock tasks to be declared' do
    define_task(namespace: :git_crypt1)
    define_task(namespace: :git_crypt2)

    expect(Rake.application).to(have_task_defined('git_crypt1:unlock'))
    expect(Rake.application).to(have_task_defined('git_crypt2:unlock'))
  end

  it 'unlocks git-crypt for the repository' do
    define_task

    stub_output
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock'].invoke

    expect(RubyGitCrypt).to(have_received(:unlock))
  end

  it 'does not pass any key paths by default' do
    define_task

    stub_output
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock'].invoke

    expect(RubyGitCrypt)
      .to(have_received(:unlock)
            .with(hash_including(key_files: nil)))
  end

  it 'passes the specified key paths when provided' do
    define_task(
      key_paths: %w[
        path/to/key1
        path/to/key2
      ]
    )

    stub_output
    stub_git_crypt_unlock

    Rake::Task['git_crypt:unlock'].invoke

    expect(RubyGitCrypt)
      .to(have_received(:unlock)
            .with(hash_including(key_files: %w[
                                   path/to/key1
                                   path/to/key2
                                 ])))
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

  def stub_git_crypt_unlock
    allow(RubyGitCrypt).to(receive(:unlock))
  end
end
