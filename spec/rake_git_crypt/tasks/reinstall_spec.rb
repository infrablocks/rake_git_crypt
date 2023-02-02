# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::Reinstall do
  include_context 'rake'

  # rubocop:disable Metrics/MethodLength
  def define_task(opts = {}, &block)
    opts = {
      namespace: :git_crypt,
      additional_namespaced_tasks: %i[install uninstall],
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

  it 'adds a reinstall task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:reinstall'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:reinstall'].full_comment)
      .to(eq('Reinstall git-crypt.'))
  end

  describe 'by default' do
    it 'uninstalls git-crypt using the default uninstall task' do
      define_task

      stub_output
      stub_task('git_crypt:uninstall')
      stub_task('git_crypt:install')

      Rake::Task['git_crypt:reinstall'].invoke

      expect(Rake::Task['git_crypt:uninstall'])
        .to(have_received(:invoke))
    end

    it 'installs git-crypt using the default install task' do
      define_task

      stub_output
      stub_task('git_crypt:uninstall')
      stub_task('git_crypt:install')

      Rake::Task['git_crypt:reinstall'].invoke

      expect(Rake::Task['git_crypt:install'])
        .to(have_received(:invoke))
    end
  end

  describe 'when uninstall_task_name provided and task is defined' do
    it 'uninstalls git-crypt using the specified uninstall task' do
      define_task(
        uninstall_task_name: :remove,
        additional_namespaced_tasks: %i[install remove]
      )

      stub_output
      stub_task('git_crypt:remove')
      stub_task('git_crypt:install')

      Rake::Task['git_crypt:reinstall'].invoke

      expect(Rake::Task['git_crypt:remove'])
        .to(have_received(:invoke))
    end
  end

  describe 'when uninstall_task_name provided and task not defined' do
    it 'raises an error' do
      define_task(
        uninstall_task_name: :remove
      )

      stub_output
      stub_task('git_crypt:install')

      expect { Rake::Task['git_crypt:reinstall'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  describe 'when install_task_names provided and all tasks are defined' do
    it 'installs git-crypt using the specified install tasks' do
      install_task_names = %i[install_user install_admin]

      define_task(
        install_task_names: install_task_names,
        additional_namespaced_tasks: %i[install_user install_admin uninstall]
      )

      stub_output
      stub_task('git_crypt:uninstall')
      stub_task('git_crypt:install_user')
      stub_task('git_crypt:install_admin')

      Rake::Task['git_crypt:reinstall'].invoke

      install_task_names.each do |install_task_name|
        expect(Rake::Task["git_crypt:#{install_task_name}"])
          .to(have_received(:invoke))
      end
    end
  end

  describe 'when install_task_names provided and some tasks are missing' do
    it 'raises an error' do
      install_task_names = %i[install_admin install_user]

      define_task(
        install_task_names: install_task_names,
        additional_namespaced_tasks: %i[install_admin uninstall]
      )

      stub_output
      stub_task('git_crypt:uninstall')
      stub_task('git_crypt:install_admin')

      expect { Rake::Task['git_crypt:reinstall'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end

    it 'does not invoke any of the install tasks' do
      install_task_names = %i[install_admin install_user]

      define_task(
        install_task_names: install_task_names,
        additional_namespaced_tasks: %i[install_admin uninstall]
      )

      stub_output
      stub_task('git_crypt:uninstall')
      stub_task('git_crypt:install_admin')

      begin
        Rake::Task['git_crypt:reinstall'].invoke
      rescue RakeFactory::DependencyTaskMissing
        # no-op
      end

      expect(Rake::Task['git_crypt:install_admin'])
        .not_to(have_received(:invoke))
    end
  end

  describe 'when install_task_names provided and all tasks are missing' do
    it 'raises an error' do
      install_task_names = %i[install_admin install_user]

      define_task(
        install_task_names: install_task_names
      )

      stub_output
      stub_task('git_crypt:uninstall')

      expect { Rake::Task['git_crypt:reinstall'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_task(task_name)
    allow(Rake::Task[task_name]).to(receive(:invoke))
    allow(Rake::Task[task_name]).to(receive(:reenable))
  end
end
