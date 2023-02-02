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

      def ensure_task_with_name_available(task, name)
        raise_task_undefined(name) unless task_defined?(task, name)
      end

      def invoke_task_with_name(task, name, args)
        ensure_task_with_name_available(task, name)
        task_by_name(task, name).invoke(*args)
      end

      def reenable_task_with_name(task, name)
        ensure_task_with_name_available(task, name)
        task_by_name(task, name).reenable
      end

      def invoke_and_reenable_task_with_name(task, name, args)
        invoke_task_with_name(task, name, args)
        reenable_task_with_name(task, name)
      end

      def raise_task_undefined(name)
        raise(
          RakeFactory::DependencyTaskMissing,
          "The task with name #{name} does not exist."
        )
      end
    end
  end
end
