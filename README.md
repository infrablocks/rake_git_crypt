# RakeGitCrypt

Rake tasks for interacting with git-crypt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rake_git_crypt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rake_git_crypt

## Usage

TODO: Write docs.

### Unlocking git-crypt with an encrypted GPG key

The `unlock_with_encrypted_gpg_key` task unlocks git-crypt using a
passphrase-encrypted GPG key, useful in CI environments. It decrypts an
OpenSSL-encrypted GPG private key, imports it into GPG and runs
`git-crypt unlock`. The passphrase is read from an environment variable so
that it never appears on the process command line.

By default the key is imported into a temporary GPG home directory (created
under the GPG work directory) which is used for both the import and the
`git-crypt unlock`, so the private key never lands in the default keyring
and does not persist after the task completes. A specific home directory can
be provided via `gpg_home_directory`, in which case it is used as-is.

```ruby
require 'rake_git_crypt'

RakeGitCrypt::Tasks::UnlockWithEncryptedGPGKey.define(
  encrypted_key_path: '.github/gpg.private.enc',
  passphrase_env_var_name: 'ENCRYPTION_PASSPHRASE'
)
```

Both parameters are optional and default to the values shown above. The task
is also included in the standard task set, where the same settings can be
provided via `unlock_with_encrypted_gpg_key_encrypted_key_path` and
`unlock_with_encrypted_gpg_key_passphrase_env_var_name`, with the GPG home
and work directories controlled by the shared `gpg_home_directory` and
`gpg_work_directory` settings.

The passphrase is expected to be provided as a secret (for example the
`ENCRYPTION_PASSPHRASE` GitHub Actions or Dependabot secret) and exposed to
the step that runs the task:

```bash
ENCRYPTION_PASSPHRASE="..." bundle exec rake unlock_with_encrypted_gpg_key
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/infrablocks/rake_git_crypt. This project is intended to be a 
safe, welcoming space for collaboration, and contributors are expected to 
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of 
conduct.

## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
