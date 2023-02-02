# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::AddUsers do
  include_context 'rake'

  # rubocop:disable Metrics/MethodLength
  def define_task(opts = {}, &block)
    opts = {
      namespace: :git_crypt,
      additional_namespaced_tasks: %i[add_user_by_id add_user_by_key_path],
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

  it 'adds an add_users task in the namespace in which it is created' do
    define_task

    expect(Rake.application)
      .to(have_task_defined('git_crypt:add_users'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git_crypt:add_users'].full_comment)
      .to(eq('Add users to git-crypt.'))
  end

  it 'allows multiple add_users tasks to be declared' do
    define_task(namespace: :git_crypt1)
    define_task(namespace: :git_crypt2)

    expect(Rake.application).to(have_task_defined('git_crypt1:add_users'))
    expect(Rake.application).to(have_task_defined('git_crypt2:add_users'))
  end

  describe 'when neither gpg_user_key_paths or gpg_user_ids are provided' do
    it 'raises an error' do
      define_task

      stub_output
      stub_task('git_crypt:add_user_by_id')
      stub_task('git_crypt:add_user_by_key_path')

      expect { Rake::Task['git_crypt:add_users'].invoke }
        .to(raise_error(RakeFactory::RequiredParameterUnset))
    end
  end

  describe 'when gpg_user_key_paths provided' do
    describe 'when key paths represent files' do
      it 'calls the add_user_by_key_path task for each provided key path ' \
         'by default' do
        gpg_user_key_paths = %w[
          path/to/key1.gpg
          path/to/key2.gpg
        ]

        define_task(gpg_user_key_paths: gpg_user_key_paths)

        stub_output
        stub_file('path/to/key1.gpg')
        stub_file('path/to/key2.gpg')
        stub_task('git_crypt:add_user_by_id')
        stub_task('git_crypt:add_user_by_key_path')

        Rake::Task['git_crypt:add_users'].invoke

        gpg_user_key_paths.each do |key_path|
          expect(Rake::Task['git_crypt:add_user_by_key_path'])
            .to(have_received(:invoke)
                  .with(key_path))
        end

        expect(Rake::Task['git_crypt:add_user_by_key_path'])
          .to(have_received(:reenable)
                .twice)
      end

      it 'calls the task specified in add_user_by_key_path_task_name for ' \
         'each provided key path when provided' do
        gpg_user_key_paths = %w[
          path/to/key1.gpg
          path/to/key2.gpg
        ]

        define_task(
          additional_namespaced_tasks: %i[add_by_id add_by_key],
          gpg_user_key_paths: gpg_user_key_paths,
          add_user_by_key_path_task_name: :add_by_key,
          add_user_by_id_task_name: :add_by_id
        )

        stub_output
        stub_file('path/to/key1.gpg')
        stub_file('path/to/key2.gpg')
        stub_task('git_crypt:add_by_id')
        stub_task('git_crypt:add_by_key')

        Rake::Task['git_crypt:add_users'].invoke

        gpg_user_key_paths.each do |key_path|
          expect(Rake::Task['git_crypt:add_by_key'])
            .to(have_received(:invoke)
                  .with(key_path))
        end

        expect(Rake::Task['git_crypt:add_by_key'])
          .to(have_received(:reenable)
                .twice)
      end
    end

    describe 'when key paths represent directories' do
      it 'calls the add_user_by_key_path task for each file within the ' \
         'key paths by default' do
        gpg_user_key_paths = %w[
          path/to/keys1
          path/to/keys2
        ]

        define_task(gpg_user_key_paths: gpg_user_key_paths)

        stub_output
        stub_file('path/to/keys1/key1.gpg')
        stub_file('path/to/keys2/key1.gpg')
        stub_file('path/to/keys2/key2.gpg')
        stub_directory(
          'path/to/keys1',
          ['key1.gpg']
        )
        stub_directory(
          'path/to/keys2',
          %w[key1.gpg key2.gpg]
        )
        stub_task('git_crypt:add_user_by_id')
        stub_task('git_crypt:add_user_by_key_path')

        Rake::Task['git_crypt:add_users'].invoke

        %w[
          path/to/keys1/key1.gpg
          path/to/keys2/key1.gpg
          path/to/keys2/key2.gpg
        ].each do |key_path|
          expect(Rake::Task['git_crypt:add_user_by_key_path'])
            .to(have_received(:invoke)
                  .with(key_path))
        end

        expect(Rake::Task['git_crypt:add_user_by_key_path'])
          .to(have_received(:reenable)
                .thrice)
      end

      it 'calls the task specified in add_user_by_key_path_task_name for ' \
         'each file within the provided key paths when provided' do
        gpg_user_key_paths = %w[
          path/to/keys1
          path/to/keys2
        ]

        define_task(
          additional_namespaced_tasks: %i[add_by_id add_by_key],
          gpg_user_key_paths: gpg_user_key_paths,
          add_user_by_key_path_task_name: :add_by_key,
          add_user_by_id_task_name: :add_by_id
        )

        stub_output
        stub_file('path/to/keys1/key1.gpg')
        stub_file('path/to/keys2/key1.gpg')
        stub_file('path/to/keys2/key2.gpg')
        stub_directory(
          'path/to/keys1',
          ['key1.gpg']
        )
        stub_directory(
          'path/to/keys2',
          %w[key1.gpg key2.gpg]
        )
        stub_task('git_crypt:add_by_id')
        stub_task('git_crypt:add_by_key')

        Rake::Task['git_crypt:add_users'].invoke

        %w[
          path/to/keys1/key1.gpg
          path/to/keys2/key1.gpg
          path/to/keys2/key2.gpg
        ].each do |key_path|
          expect(Rake::Task['git_crypt:add_by_key'])
            .to(have_received(:invoke)
                  .with(key_path))
        end

        expect(Rake::Task['git_crypt:add_by_key'])
          .to(have_received(:reenable)
                .thrice)
      end
    end

    it 'raises an error when add_user_by_key_path_task_name is nil' do
      gpg_user_key_paths = %w[
        path/to/key1.gpg
        path/to/key2.gpg
      ]

      define_task(
        gpg_user_key_paths: gpg_user_key_paths,
        add_user_by_key_path_task_name: nil
      )

      stub_output
      stub_file('path/to/key1.gpg')
      stub_file('path/to/key2.gpg')
      stub_task('git_crypt:add_user_by_id')

      expect { Rake::Task['git_crypt:add_users'].invoke }
        .to(raise_error(RakeFactory::RequiredParameterUnset))
    end

    it 'raises an error when the add user by key path task is required ' \
       'but not present' do
      gpg_user_key_paths = %w[
        path/to/key1.gpg
        path/to/key2.gpg
      ]

      define_task(
        gpg_user_key_paths: gpg_user_key_paths,
        add_user_by_key_path_task_name: :missing_task
      )

      stub_output
      stub_file('path/to/key1.gpg')
      stub_file('path/to/key2.gpg')
      stub_task('git_crypt:add_user_by_id')

      expect { Rake::Task['git_crypt:add_users'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  describe 'when gpg_user_ids provided' do
    it 'calls the add_user_by_id task for each provided key path ' \
       'by default' do
      gpg_user_ids = %w[
        41D2606F66C3FF28874362B61A16916844CE9D82
        D164A61C69E23C0F74475FBE5FFE76AD095FCA07
      ]

      define_task(gpg_user_ids: gpg_user_ids)

      stub_output
      stub_task('git_crypt:add_user_by_id')
      stub_task('git_crypt:add_user_by_key_path')

      Rake::Task['git_crypt:add_users'].invoke

      gpg_user_ids.each do |id|
        expect(Rake::Task['git_crypt:add_user_by_id'])
          .to(have_received(:invoke)
                .with(id))
      end

      expect(Rake::Task['git_crypt:add_user_by_id'])
        .to(have_received(:reenable)
              .twice)
    end

    it 'calls the task specified in add_user_by_id_task_name for ' \
       'each provided ID when provided' do
      gpg_user_ids = %w[
        41D2606F66C3FF28874362B61A16916844CE9D82
        D164A61C69E23C0F74475FBE5FFE76AD095FCA07
      ]

      define_task(
        additional_namespaced_tasks: %i[add_by_id add_by_key],
        gpg_user_ids: gpg_user_ids,
        add_user_by_key_path_task_name: :add_by_key,
        add_user_by_id_task_name: :add_by_id
      )

      stub_output
      stub_task('git_crypt:add_by_id')
      stub_task('git_crypt:add_by_key')

      Rake::Task['git_crypt:add_users'].invoke

      gpg_user_ids.each do |id|
        expect(Rake::Task['git_crypt:add_by_id'])
          .to(have_received(:invoke)
                .with(id))
      end

      expect(Rake::Task['git_crypt:add_by_id'])
        .to(have_received(:reenable)
              .twice)
    end

    it 'raises an error when add_user_by_id_task_name is nil' do
      gpg_user_ids = %w[
        41D2606F66C3FF28874362B61A16916844CE9D82
        D164A61C69E23C0F74475FBE5FFE76AD095FCA07
      ]

      define_task(
        gpg_user_ids: gpg_user_ids,
        add_user_by_id_task_name: nil
      )

      stub_output
      stub_task('git_crypt:add_user_by_key_path')

      expect { Rake::Task['git_crypt:add_users'].invoke }
        .to(raise_error(RakeFactory::RequiredParameterUnset))
    end

    it 'raises an error when the add user by ID task is required ' \
       'but not present' do
      gpg_user_ids = %w[
        41D2606F66C3FF28874362B61A16916844CE9D82
        D164A61C69E23C0F74475FBE5FFE76AD095FCA07
      ]

      define_task(
        gpg_user_ids: gpg_user_ids,
        add_user_by_id_task_name: :missing_task
      )

      stub_output
      stub_task('git_crypt:add_user_by_key_path')

      expect { Rake::Task['git_crypt:add_users'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  describe 'when both gpg_user_key_paths and gpg_user_ids ' \
           'are provided' do
    # rubocop:disable RSpec/ExampleLength
    it 'adds all specified users' do
      gpg_user_key_paths = %w[
        path/to/key1.gpg
        path/to/keys/
      ]
      gpg_user_ids = %w[
        41D2606F66C3FF28874362B61A16916844CE9D82
        D164A61C69E23C0F74475FBE5FFE76AD095FCA07
      ]

      define_task(
        gpg_user_ids: gpg_user_ids,
        gpg_user_key_paths: gpg_user_key_paths
      )

      stub_output
      stub_file('path/to/key1.gpg')
      stub_file('path/to/keys/key2.gpg')
      stub_file('path/to/keys/nested/key3.gpg')
      stub_directory(
        'path/to/keys/',
        %w[key2.gpg nested]
      )
      stub_directory(
        'path/to/keys/nested',
        %w[key3.gpg]
      )
      stub_task('git_crypt:add_user_by_id')
      stub_task('git_crypt:add_user_by_key_path')

      Rake::Task['git_crypt:add_users'].invoke

      gpg_user_ids.each do |id|
        expect(Rake::Task['git_crypt:add_user_by_id'])
          .to(have_received(:invoke)
                .with(id))
      end

      expect(Rake::Task['git_crypt:add_user_by_id'])
        .to(have_received(:reenable)
              .twice)

      %w[
        path/to/key1.gpg
        path/to/keys/key2.gpg
        path/to/keys/nested/key3.gpg
      ].each do |key_path|
        expect(Rake::Task['git_crypt:add_user_by_key_path'])
          .to(have_received(:invoke)
                .with(key_path))
      end

      expect(Rake::Task['git_crypt:add_user_by_key_path'])
        .to(have_received(:reenable)
              .thrice)
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe 'when commit_task_name provided and task is defined' do
    it 'commits with an appropriate message by default' do
      gpg_user_key_paths = %w[
        path/to/key.gpg
      ]

      define_task(
        gpg_user_key_paths: gpg_user_key_paths,
        commit_task_name: :'git:commit',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_file('path/to/key.gpg')
      stub_task('git_crypt:add_user_by_key_path')
      stub_task('git:commit')

      Rake::Task['git_crypt:add_users'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke)
              .with('Adding users to git-crypt.'))
    end

    it 're-enables the commit task' do
      gpg_user_key_paths = %w[
        path/to/key.gpg
      ]

      define_task(
        gpg_user_key_paths: gpg_user_key_paths,
        commit_task_name: :'git:commit',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_file('path/to/key.gpg')
      stub_task('git_crypt:add_user_by_key_path')
      stub_task('git:commit')

      Rake::Task['git_crypt:add_users'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:reenable))
    end

    it 'invokes and re-enables the commit task in the correct order' do
      gpg_user_key_paths = %w[
        path/to/key.gpg
      ]

      define_task(
        gpg_user_key_paths: gpg_user_key_paths,
        commit_task_name: :'git:commit',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_file('path/to/key.gpg')
      stub_task('git_crypt:add_user_by_key_path')
      stub_task('git:commit')

      Rake::Task['git_crypt:add_users'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git:commit'])
        .to(have_received(:reenable).ordered)
    end

    it 'uses the specified commit message template when provided' do
      gpg_user_key_paths = %w[
        path/to/key.gpg
      ]

      define_task(
        gpg_user_key_paths: gpg_user_key_paths,
        commit_task_name: :'git:commit',
        commit_message_template:
          'Adding git-crypt users: <%= @task.gpg_user_key_paths %>.',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_file('path/to/key.gpg')
      stub_task('git_crypt:add_user_by_key_path')
      stub_task('git:commit')

      Rake::Task['git_crypt:add_users'].invoke

      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke)
              .with('Adding git-crypt users: ["path/to/key.gpg"].'))
    end

    it 'calls commit after adding the GPG users' do
      gpg_user_key_paths = %w[
        path/to/key.gpg
      ]

      define_task(
        gpg_user_key_paths: gpg_user_key_paths,
        commit_task_name: :'git:commit',
        additional_top_level_tasks: %i[git:commit]
      )

      stub_output
      stub_file('path/to/key.gpg')
      stub_task('git_crypt:add_user_by_key_path')
      stub_task('git:commit')

      Rake::Task['git_crypt:add_users'].invoke

      expect(Rake::Task['git_crypt:add_user_by_key_path'])
        .to(have_received(:invoke).ordered)
      expect(Rake::Task['git_crypt:add_user_by_key_path'])
        .to(have_received(:reenable).ordered)
      expect(Rake::Task['git:commit'])
        .to(have_received(:invoke).ordered)
    end
  end

  describe 'when commit_task_name provided and task not defined' do
    it 'raises an error' do
      gpg_user_key_paths = %w[
        path/to/key.gpg
      ]

      define_task(
        gpg_user_key_paths: gpg_user_key_paths,
        commit_task_name: :'git:commit',
        commit_message: 'Adding git-crypt users.'
      )

      stub_output
      stub_file('path/to/key.gpg')
      stub_task('git_crypt:add_user_by_key_path')

      expect { Rake::Task['git_crypt:add_users'].invoke }
        .to(raise_error(RakeFactory::DependencyTaskMissing))
    end
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_file(path)
    allow(File).to(receive(:file?).with(path).and_return(true))
    allow(File).to(receive(:directory?).with(path).and_return(false))
  end

  def stub_directory(path, entries)
    allow(File).to(receive(:file?).with(path).and_return(false))
    allow(File).to(receive(:directory?).with(path).and_return(true))
    allow(Dir)
      .to(receive(:entries)
            .with(path)
            .and_return(['.', '..', *entries]))
  end

  def stub_task(task_name)
    allow(Rake::Task[task_name]).to(receive(:invoke))
    allow(Rake::Task[task_name]).to(receive(:reenable))
  end
end
