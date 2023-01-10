TODO
====

* Finish AddUser task
  * Add option to commit?

* Add AddUsers task
  * Add many users at once
* Add RemoveUser task
  * Remove user for key name
  * By ID or by key path
  * Delete key?
  * Would need to uninstall and reinstall git-crypt in the process
  * Would need to rotate all secrets in the process

* Add Install task
  * Init git crypt
  * Add all users
  * Optionally commit?
* Add Uninstall task
  * Delete .git/git-crypt directory
  * Delete .git-crypt directory
  * Delete secrets from paths?

* Add Reinstall task
  * Unlock? 
  * Execute uninstall task
  * Execute install task
  * Regenerate secrets?
