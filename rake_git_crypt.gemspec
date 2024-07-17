# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_git_crypt/version'

files = %w[
  bin
  lib
  CODE_OF_CONDUCT.md
  rake_git_crypt.gemspec
  Gemfile
  LICENSE.txt
  Rakefile
  README.md
]

Gem::Specification.new do |spec|
  spec.name = 'rake_git_crypt'
  spec.version = RakeGitCrypt::VERSION
  spec.authors = ['InfraBlocks Maintainers']
  spec.email = ['maintainers@infrablocks.io']

  spec.summary = 'Rake tasks for interacting with git-crypt.'
  spec.description =
    'Allows initialising, locking, unlocking and managing users for git-crypt.'
  spec.homepage = 'https://github.com/infrablocks/rake_git_crypt'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(/^(#{files.map { |g| Regexp.escape(g) }.join('|')})/)
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1'

  spec.add_dependency 'colored2', '~> 3.1'
  spec.add_dependency 'rake_factory', '~> 0.33'
  spec.add_dependency 'ruby_git_crypt', '~> 0.1'
  spec.add_dependency 'ruby_gpg2', '~> 0.12'

  spec.metadata['rubygems_mfa_required'] = 'false'
end
