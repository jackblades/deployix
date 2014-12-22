execve
=======

`execve` creates a program that sets up the execution environment as requested
and then executes a program with given arguments and environment variables.

Arguments
----------

* `name`: The name of the resultant executable.
* `filename`: The binary to execute
* `argv`: The list of arguments to pass. First argument is passed as `argv[0]`
* `envp`: Optional, set of environment variable values. If not set, takes from parent.
* `settings`: Optional, set of general execution environment flags:
  * `user`: The user to switch to.
  * `group`: The group to switch to.
  * `restart`: The restart mode (see `restart-modes` in
     `<defnix/lib/default.nix>`). Defaults to `restart-modes.no`.
  * `working-directory`: The directory to change to before executing
  * `bind-mounts`: A set whose names correspond to paths to be bind-mounted
    from the path in the value. If non-empty, the process will run in a private
    mount namespace.

Exit codes
----------

* 212: Failed to execute
* 213: Failed to change user/group
* 214: Error setting up mounts
* 215: Error changing directory

Example
--------

`execve "call-foo" { filename = "${foo}/bin/foo"; argv = [ "foo" "--bar" ]; envp = { baz = "qux"; }; }`
will result in an executable `call-foo` that, when called, calls `${foo}/bin/foo`
with the argument `--bar` and the environment variable `baz` set to `qux`
