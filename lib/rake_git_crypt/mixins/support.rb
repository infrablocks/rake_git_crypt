# frozen_string_literal: true

module RakeGitCrypt
  module Mixins
    module Support
      def task_by_name(task, name)
        task.application.lookup(name, task.scope)
      end

      def task_defined?(task, name)
        !task_by_name(task, name).nil?
      end

      def invoke_task_with_name(task, name, args)
        task_by_name(task, name).invoke(*args)
      end
    end
  end
end
