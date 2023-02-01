# frozen_string_literal: true

require 'erb'

module RakeGitCrypt
  class Template
    def self.from_file(path)
      new(File.read(path))
    end

    def initialize(contents)
      @contents = contents
    end

    def render(parameters = {})
      context = Object.new
      parameters.each do |key, value|
        context.instance_variable_set("@#{key}", value)
      end
      context_binding = context.instance_eval { binding }
      ERB.new(@contents).result(context_binding)
    end
  end
end
