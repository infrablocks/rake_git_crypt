# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::Install do
  include_context 'rake'

  # rubocop:disable Metrics/MethodLength
  def define_task(opts = {}, &block)
    opts = {
      namespace: :git_crypt,
      additional_namespaced_tasks: %i[init add_users],
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

  it 'adds an install task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:install'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:install'].full_comment)
      .to(eq('Install git-crypt.'))
  end

  it 'allows multiple install tasks to be declared' do
    define_task(namespace: :git_crypt1)
    define_task(namespace: :git_crypt2)

    expect(Rake.application).to(have_task_defined('git_crypt1:install'))
    expect(Rake.application).to(have_task_defined('git_crypt2:install'))
  end

  describe 'by default' do
    it 'inits git-crypt using the default init task' do
      define_task

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:init'])
        .to(have_received(:invoke))
    end

    it 're-enables the default init task' do
      define_task

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:init'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the default init task in the correct order' do
      define_task

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:init'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:init'])
        .to(have_received(:reenable).ordered)
    end

    it 'adds users to git-crypt using the default add users task' do
      define_task

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:add_users'])
        .to(have_received(:invoke))
    end

    it 're-enables the default add users task' do
      define_task

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:add_users'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the default add users task in the ' \
       'correct order' do
      define_task

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:add_users'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:add_users'])
        .to(have_received(:reenable).ordered)
    end

    it 'inits before adding users' do
      define_task

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:init'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:add_users'])
        .to(have_received(:invoke).ordered)
    end
  end

  describe 'when init_task_name provided and task is defined' do
    it 'inits git-crypt using the specified init task' do
      define_task(
        init_task_name: :init_admin_key,
        additional_namespaced_tasks: %i[init_admin_key add_users]
      )

      stub_output
      stub_task('git_crypt:init_admin_key')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:init_admin_key'])
        .to(have_received(:invoke))
    end

    it 're-enables the specified init task' do
      define_task(
        init_task_name: :init_admin_key,
        additional_namespaced_tasks: %i[init_admin_key add_users]
      )

      stub_output
      stub_task('git_crypt:init_admin_key')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:init_admin_key'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the specified init task in the correct order' do
      define_task(
        init_task_name: :init_admin_key,
        additional_namespaced_tasks: %i[init_admin_key add_users]
      )

      stub_output
      stub_task('git_crypt:init_admin_key')
      stub_task('git_crypt:add_users')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:init_admin_key'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:init_admin_key'])
        .to(have_received(:reenable).ordered)
    end
  end

  describe 'when init_task_name provided and task not defined' do
    it 'raises an error' do
      define_task(
        init_task_name: :init_user_key
      )

      stub_output
      stub_task('git_crypt:add_users')

      expect { Rake::Task['git_crypt:install'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  describe 'when add_users_task_name provided and task is defined' do
    it 'adds users to git-crypt using the specified add users task' do
      define_task(
        add_users_task_name: :add_users_for_admin_key,
        additional_namespaced_tasks: %i[add_users_for_admin_key init]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users_for_admin_key')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:add_users_for_admin_key'])
        .to(have_received(:invoke))
    end

    it 're-enables the specified add users task' do
      define_task(
        add_users_task_name: :add_users_for_admin_key,
        additional_namespaced_tasks: %i[add_users_for_admin_key init]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users_for_admin_key')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:add_users_for_admin_key'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the specified add users task in the ' \
       'correct order' do
      define_task(
        add_users_task_name: :add_users_for_admin_key,
        additional_namespaced_tasks: %i[add_users_for_admin_key init]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users_for_admin_key')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:add_users_for_admin_key'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:add_users_for_admin_key'])
        .to(have_received(:reenable).ordered)
    end
  end

  describe 'when add_users_task_name provided and task not defined' do
    it 'raises an error' do
      define_task(
        add_users_task_name: :add_users_for_user_key
      )

      stub_output
      stub_task('git_crypt:init')

      expect { Rake::Task['git_crypt:install'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  describe 'when provision_secrets_task_name provided and task is defined' do
    it 'provisions secrets using the specified task' do
      define_task(
        provision_secrets_task_name: :'secrets:provision',
        additional_top_level_tasks: %i[secrets:provision]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('secrets:provision')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['secrets:provision'])
        .to(have_received(:invoke))
    end

    it 're-enables the specified provision secrets task' do
      define_task(
        provision_secrets_task_name: :'secrets:provision',
        additional_top_level_tasks: %i[secrets:provision]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('secrets:provision')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['secrets:provision'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the specified provision secrets task in the ' \
       'correct order' do
      define_task(
        provision_secrets_task_name: :'secrets:provision',
        additional_top_level_tasks: %i[secrets:provision]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('secrets:provision')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['secrets:provision'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['secrets:provision'])
        .to(have_received(:reenable).ordered)
    end

    it 'invokes the specified provision secrets task before adding users' do
      define_task(
        provision_secrets_task_name: :'secrets:provision',
        additional_top_level_tasks: %i[secrets:provision]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('secrets:provision')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['secrets:provision'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:add_users'])
        .to(have_received(:invoke).ordered)
    end

    it 'invokes the specified provision secrets task after initing git-crypt' do
      define_task(
        provision_secrets_task_name: :'secrets:provision',
        additional_top_level_tasks: %i[secrets:provision]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('secrets:provision')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:init'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['secrets:provision'])
        .to(have_received(:invoke).ordered)
    end
  end

  describe 'when provision_secrets_task_name provided and task not defined' do
    it 'raises an error' do
      define_task(
        provision_secrets_task_name: :'secrets:provision'
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      expect { Rake::Task['git_crypt:install'].invoke }
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
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('git:commit')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke)
              .with('Installing git-crypt.'))
    end

    it 're-enables the specified commit task' do
      define_task(
        commit_task_name: :'git:commit',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('git:commit')

      Rake::Task['git_crypt:install'].invoke

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
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('git:commit')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git:commit'])
        .to(have_received(:reenable).ordered)
    end

    it 'uses the specified commit message template when provided' do
      define_task(
        commit_task_name: :'git:commit',
        commit_message_template: 'Adding git-crypt.',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('git:commit')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke)
              .with('Adding git-crypt.'))
    end

    it 'calls commit after installing git crypt' do
      define_task(
        commit_task_name: :'git:commit',
        commit_message_template: 'Adding git-crypt.',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')
      stub_task('git:commit')

      Rake::Task['git_crypt:install'].invoke

      expect(Rake::Task['git_crypt:add_users'])
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
      stub_task('git_crypt:init')
      stub_task('git_crypt:add_users')

      expect { Rake::Task['git_crypt:install'].invoke }
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
