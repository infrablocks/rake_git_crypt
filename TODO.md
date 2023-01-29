TODO
====

* Finish AddUser task
  * Optionally commit?

* Add AddUsers task
  * Allow specifying key directory instead of individual key paths
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
  * Optionally commit?

* Add Reinstall task
  * Unlock? 
  * Execute uninstall task
  * Execute install task
  * Regenerate secrets?
