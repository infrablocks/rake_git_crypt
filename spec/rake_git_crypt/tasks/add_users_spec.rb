# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::AddUsers do
  include_context 'rake'

  def define_task(opts = {}, &block)
    opts = {
      namespace: :git_crypt,
      additional_tasks: %i[add_user_by_id add_user_by_key_path]
    }.merge(opts)

    namespace opts[:namespace] do
      opts[:additional_tasks].each do |t|
        task t
      end

      subject.define(opts, &block)
    end
  end

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
    it 'calls the add_user_by_key_path task for each provided key path ' \
       'by default' do
      gpg_user_key_paths = %w[
        path/to/key1.gpg
        path/to/key2.gpg
      ]

      define_task(gpg_user_key_paths: gpg_user_key_paths)

      stub_output
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
        additional_tasks: %i[add_by_id add_by_key],
        gpg_user_key_paths: gpg_user_key_paths,
        add_user_by_key_path_task_name: :add_by_key,
        add_user_by_id_task_name: :add_by_id
      )

      stub_output
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
        additional_tasks: %i[add_by_id add_by_key],
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
    it 'adds all specified users' do
      gpg_user_key_paths = %w[
        path/to/key1.gpg
        path/to/key2.gpg
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

      gpg_user_key_paths.each do |key_path|
        expect(Rake::Task['git_crypt:add_user_by_key_path'])
          .to(have_received(:invoke)
                .with(key_path))
      end

      expect(Rake::Task['git_crypt:add_user_by_key_path'])
        .to(have_received(:reenable)
              .twice)
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
