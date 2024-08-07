# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::Uninstall do
  include_context 'rake'

  # rubocop:disable Metrics/MethodLength
  def define_task(opts = {}, &)
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

      subject.define(opts, &)
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

    it 're-enables the default lock task' do
      define_task

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git_crypt:lock'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the default lock task in the correct order' do
      define_task

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git_crypt:lock'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:lock'])
        .to(have_received(:reenable).ordered)
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

  describe 'when lock_task_name provided and task is defined' do
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

    it 're-enables the specified lock task' do
      define_task(
        lock_task_name: :lock_all,
        additional_namespaced_tasks: %i[lock_all]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock_all')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git_crypt:lock_all'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the specified lock task in the correct order' do
      define_task(
        lock_task_name: :lock_all,
        additional_namespaced_tasks: %i[lock_all]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock_all')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git_crypt:lock_all'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:lock_all'])
        .to(have_received(:reenable).ordered)
    end
  end

  describe 'when lock_task_name provided and task not defined' do
    it 'raises an error' do
      define_task(
        lock_task_name: :lock_admin_key,
        additional_top_level_tasks: %i[secrets:destroy]
      )

      stub_output
      stub_rm_rf
      stub_task('secrets:destroy')

      expect { Rake::Task['git_crypt:uninstall'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  describe 'when destroy_secrets_task_name provided and task is defined' do
    it 'deletes secrets using the specified task' do
      define_task(
        destroy_secrets_task_name: :'secrets:destroy',
        additional_top_level_tasks: %i[secrets:destroy]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('secrets:destroy')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['secrets:destroy'])
        .to(have_received(:invoke))
    end

    it 're-enables the specified delete secrets task' do
      define_task(
        destroy_secrets_task_name: :'secrets:destroy',
        additional_top_level_tasks: %i[secrets:destroy]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('secrets:destroy')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['secrets:destroy'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the specified delete secrets task in the ' \
       'correct order' do
      define_task(
        destroy_secrets_task_name: :'secrets:destroy',
        additional_top_level_tasks: %i[secrets:destroy]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('secrets:destroy')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['secrets:destroy'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['secrets:destroy'])
        .to(have_received(:reenable).ordered)
    end
  end

  describe 'when destroy_secrets_task_name provided and task not defined' do
    it 'raises an error' do
      define_task(
        destroy_secrets_task_name: :'secrets:destroy'
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')

      expect { Rake::Task['git_crypt:uninstall'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  describe 'when commit_task_name provided and task is defined' do
    it 'commits with an appropriate message by default' do
      define_task(
        commit_task_name: :'git:commit',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('git:commit')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke)
              .with('Uninstalling git-crypt.'))
    end

    it 're-enables the specified commit task' do
      define_task(
        commit_task_name: :'git:commit',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('git:commit')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the specified commit task in the ' \
       'correct order' do
      define_task(
        commit_task_name: :'git:commit',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('git:commit')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git:commit'])
        .to(have_received(:reenable).ordered)
    end

    it 'uses the specified commit message when provided' do
      define_task(
        commit_task_name: :'git:commit',
        commit_message_template: 'Removing git-crypt.',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('git:commit')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke)
              .with('Removing git-crypt.'))
    end

    it 'calls commit after uninstalling git crypt' do
      define_task(
        destroy_secrets_task_name: :'secrets:destroy',
        commit_task_name: :'git:commit',
        commit_message_template: 'Removing git-crypt.',
        additional_top_level_tasks: %i[git:commit secrets:destroy]
      )

      stub_output
      stub_rm_rf
      stub_task('git_crypt:lock')
      stub_task('secrets:destroy')
      stub_task('git:commit')

      Rake::Task['git_crypt:uninstall'].invoke

      expect(Rake::Task['git_crypt:lock'])
        .to(have_received(:invoke).ordered)
      expect(FileUtils)
        .to(have_received(:rm_rf)
              .with('.git-crypt').ordered)
      expect(FileUtils)
        .to(have_received(:rm_rf)
              .with('.git/git-crypt').ordered)
      expect(Rake::Task['secrets:destroy'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke).ordered)
    end
  end

  describe 'when commit_task_name provided and task not defined' do
    it 'raises an error' do
      define_task(
        commit_task_name: :'git:commit'
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
