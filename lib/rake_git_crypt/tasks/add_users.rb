# frozen_string_literal: true

require 'rake_factory'

require_relative '../mixins/support'

module RakeGitCrypt
  module Tasks
    # rubocop:disable Metrics/ClassLength
    class AddUsers < RakeFactory::Task
      include Mixins::Support

      default_name :add_users
      default_description 'Add users to git-crypt.'

      parameter :gpg_user_key_paths, default: []
      parameter :gpg_user_ids, default: []

      parameter(:commit_message_template,
                default: 'Adding users to git-crypt.')

      parameter(
        :add_user_by_id_task_name,
        default: :add_user_by_id
      )
      parameter(
        :add_user_by_key_path_task_name,
        default: :add_user_by_key_path
      )
      parameter(:commit_task_name)

      action do |task, args|
        ensure_users_provided
        ensure_tasks_present(task)

        add_users_by_key_paths(task, args)
        add_users_by_ids(task, args)
        maybe_commit(task, args)
      end

      def gpg_user_key_paths
        parameter = self.class.parameter_set.find(:gpg_user_key_paths)
        key_paths = parameter.get(self)

        return nil if key_paths.nil?

        resolve_key_paths(key_paths)
      end

      private

      def resolve_key_paths(paths)
        paths.inject([]) do |acc, key_path|
          [*acc, *resolve_key_path(key_path)]
        end
      end

      def resolve_key_path(path)
        if File.file?(path)
          [path]
        elsif File.directory?(path)
          resolve_key_paths(list_directory(path))
        else
          []
        end
      end

      def list_directory(path)
        Dir.entries(path)
           .reject { |entry| %w[. ..].include?(entry) }
           .map { |entry| File.join(path, entry) }
      end

      def ensure_users_provided
        if gpg_user_details_present?(:key_path) ||
           gpg_user_details_present?(:id)
          return
        end

        raise_user_details_missing
      end

      def ensure_tasks_present(task)
        ensure_add_user_task_present(task, :id)
        ensure_add_user_task_present(task, :key_path)
      end

      def ensure_add_user_task_present(task, user_type)
        unless add_user_task_required?(user_type) && (
          add_user_task_name_missing?(user_type) ||
            !add_user_task_defined?(task, user_type))
          return
        end

        if add_user_task_name_missing?(user_type)
          raise_add_user_task_name_missing(user_type)
        else
          raise_add_user_task_undefined(user_type)
        end
      end

      def add_user_task_name_missing?(user_type)
        send(:"add_user_by_#{user_type}_task_name").nil?
      end

      def add_user_task_required?(user_type)
        gpg_user_details_present?(user_type)
      end

      def add_user_task_defined?(task, user_type)
        task_defined?(task, send(:"add_user_by_#{user_type}_task_name"))
      end

      def gpg_user_details_present?(user_type)
        !(send(:"gpg_user_#{user_type}s").nil? ||
          send(:"gpg_user_#{user_type}s").empty?)
      end

      def add_users_by_key_paths(task, args)
        add_users(task, args, :key_path)
      end

      def add_users_by_ids(task, args)
        add_users(task, args, :id)
      end

      def add_users(task, args, user_type)
        return unless gpg_user_details_present?(user_type)

        puts "Adding git-crypt users by type #{user_type}..."
        add_user_task_name = task.send(:"add_user_by_#{user_type}_task_name")
        add_user_task = task.application[add_user_task_name, task.scope]
        send(:"gpg_user_#{user_type}s").each do |detail|
          add_user_task.invoke(detail, *args)
          add_user_task.reenable
        end
      end

      def raise_add_user_task_name_missing(user_type)
        raise(
          RakeFactory::RequiredParameterUnset,
          "When gpg_user_#{user_type}s provided, " \
          "add_user_by_#{user_type}_task_name must be defined but is nil."
        )
      end

      def raise_add_user_task_undefined(user_type)
        raise(
          RakeFactory::DependencyTaskMissing,
          'The task with name defined in ' \
          "add_user_by_#{user_type}_task_name does not exist but is needed " \
          "since gpg_user_#{user_type}s provided."
        )
      end

      def raise_user_details_missing
        raise(
          RakeFactory::RequiredParameterUnset,
          'At least one of gpg_user_key_paths or gpg_user_ids ' \
          'must be provided.'
        )
      end

      def maybe_commit(task, args)
        return unless commit_task_name

        invoke_task_with_name(
          task, commit_task_name,
          [commit_message(task), *args]
        )
      end

      def commit_message(task)
        Template.new(commit_message_template)
                .render(task: task)
      end
    end

    # rubocop:enable Metrics/ClassLength
  end
end
