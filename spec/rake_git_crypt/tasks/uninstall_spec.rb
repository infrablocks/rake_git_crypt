# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::Uninstall do
  include_context 'rake'

  # rubocop:disable Metrics/MethodLength
  def define_task(opts = {}, &block)
    opts = {
      namespace: :git_crypt,
      additional_namespaced_tasks: %i[lock],
      additional_top_level_tasks: %i[]
    }.merge(opts)

    opts[:additional_top_level_tasks].each do |t|
      task t
    end

    namespace opts[:namespace] do
      opts[:additional_namespaced_tasks].each do |t|
        task t
      end

      subject.define(opts, &block)
    end
  end
  # rubocop:enable Metrics/MethodLength

  it 'adds an uninstall task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:uninstall'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:uninstall'].full_comment)
      .to(eq('Uninstall git-crypt.'))
  end

  describe 'by default' do
    it 'locks git-crypt using the default lock task' do
      define_task

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git_crypt:lock'])
        .to(have_received(:invoke))
    end

    it 'deletes the .git-crypt directory' do
      define_task

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(FileUtils)
        .to(have_received(:rm_rf)
              .with('.git-crypt'))
    end

    it 'deletes the .git/git-crypt directory' do
      define_task

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(FileUtils)
        .to(have_received(:rm_rf)
              .with('.git/git-crypt'))
    end

    it 'locks before deleting anything' do
      define_task

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git_crypt:lock'])
        .to(have_received(:invoke).ordered)
      expect(FileUtils)
        .to(have_received(:rm_rf)
              .with('.git-crypt').ordered)
      expect(FileUtils)
        .to(have_received(:rm_rf)
              .with('.git/git-crypt').ordered)
    end
  end

  describe 'when lock_task_name provided' do
    it 'locks git-crypt using the specified lock task' do
      define_task(
        lock_task_name: :lock_all,
        additional_namespaced_tasks: %i[lock_all]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock_all')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git_crypt:lock_all'])
        .to(have_received(:invoke))
    end
  end

  describe 'when delete_secrets_task_name provided and task is defined' do
    it 'deletes secrets using the specified task' do
      define_task(
        delete_secrets_task_name: :'secrets:delete',
        additional_top_level_tasks: %i[secrets:delete]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('secrets:delete')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['secrets:delete'])
        .to(have_received(:invoke))
    end
  end

  describe 'when delete_secrets_task_name provided and task not defined' do
    it 'raises an error' do
      define_task(
        delete_secrets_task_name: :'secrets:delete'
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')

      expect { Rake::Task['git_crypt:uninstall'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_rm_rf
    allow(FileUtils).to(receive(:rm_rf))
  end

  def stub_task(task_name)
    allow(Rake::Task[task_name]).to(receive(:invoke))
    allow(Rake::Task[task_name]).to(receive(:reenable))
  end
end
