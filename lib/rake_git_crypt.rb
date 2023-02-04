# frozen_string_literal: true

require 'rake_git_crypt/tasks'
require 'rake_git_crypt/task_sets'
require 'rake_git_crypt/version'

module RakeGitCrypt
  def self.define_standard_tasks(opts = {}, &block)
    RakeGitCrypt::TaskSets::Standard.define(opts, &block)
  end
end
