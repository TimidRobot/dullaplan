dullaplan
=========

Automates local config file update and port forward for connecting to a
headless Crashplan server.

"dullaplan" is a portmanteau of `Dullahan`_ and `Crashplan`_.

.. _`Dullahan`: https://en.wikipedia.org/wiki/Dullahan
.. _`Crashplan`: https://www.crashplan.com/


What it Does
------------

1. Updates local config file so that the Crashplan GUI application connects to
   the remote server via port forward instead of the local server

   A. Finds remote config file and extracts authentication token
   B. Backs up local config file
   C. Writes new local config file with remote authentication token and updated
      port number (to use SSH port forward)

2. Creates SSH connection with port forward
3. Restores local config file on exit


Usage
-----

1. Execute ``dullaplan.sh`` (example below assumes macOS local and Linux
   remote):

   A. Example invocation::

        sudo dullaplan.sh backupserver

   B. Example output::

        Parameters:
            remote_host:       backupserver
            remote_config:     /var/lib/crashplan/.ui_info
            remote_auth_token: abcdefgh-ijkl-mnop-qrst-uvwxyz012345
            local_config:      /Library/Application Support/CrashPlan/.ui_info
            local_backup:      /Library/Application Support/CrashPlan/.ui_info.bak

        Creating SSH Tunnel...
            Close this connection to revert local config

2. Open Crashplan application
3. (Complete the tasks that require the GUI)
4. Close Crashplan application
5. Quit ``dullaplan.sh`` (ex. ``^C``) or close the terminal window it was
   launched in


Install
-------

1. `Install Homebrew`_ — The missing package manager for macOS
2. Add the TimidRobot "tap" and install dullaplan::

    brew tap TimidRobot/tap
    brew install dullaplan

Alternatively, since ``dullaplan.sh`` is a bash script without esoteric
dependencies, you can simply download it and ensure it is in your ``PATH``.

.. _`Install Homebrew`: http://brew.sh/#install


Requirements
------------

- `Crashplan`_
- \*nix Operating System with

  - core utilities (``awk``, ``col``, and ``find``)
  - GNU Bourne-Again Shell (``bash``)
  - OpenSSH (``ssh``)
  - Sudo (``sudo``)


References
----------

- `Using CrashPlan On A Headless Computer - CrashPlan Support`_

.. _`Using CrashPlan On A Headless Computer - CrashPlan Support`:
    https://support.crashplan.com/Configuring/Using_CrashPlan_On_A_Headless_Computer


License
-------

- `<LICENSE>`_ (Expat/`MIT License`_)

.. _`MIT License`: http://www.opensource.org/licenses/MIT
