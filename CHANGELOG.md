# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com)
and this project adheres to
[Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- A new `unlock_ci` task has been added, along with a corresponding entry in
  the standard task set. The task decrypts an OpenSSL-encrypted CI GPG private
  key using a passphrase read from an environment variable, imports the key
  into GPG and runs `git-crypt unlock`, so that git-crypt secrets can be
  unlocked in CI without exposing the passphrase on the process command line.
  The encrypted key path (default `.github/gpg.private.enc`) and passphrase
  environment variable name (default `ENCRYPTION_PASSPHRASE`) are both
  configurable. The CI GPG key is imported into a temporary GPG home directory
  (under the configurable GPG work directory) which is also used for the
  `git-crypt unlock`, so the key never lands in the default keyring and does
  not persist after the task completes. A specific home directory can be set
  via `gpg_home_directory`.
