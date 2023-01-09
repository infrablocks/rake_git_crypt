# frozen_string_literal: true

require 'spec_helper'

describe RakeGitCrypt::Tasks::AddUsers do
  include_context 'rake'

  def define_task(opts = {}, &block)
    opts = { namespace: :git_crypt }.merge(opts)

    namespace opts[:namespace] do
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
end
