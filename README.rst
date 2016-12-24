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

1. Execute ``dullaplan`` (example below assumes Mac OS local and Linux
   remote)::

    sudo dullaplan.sh backupserver

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
5. Quit ``dullaplan`` (ex. ``^C``) or close the terminal window it was launched
   in


References
----------

- `Using CrashPlan On A Headless Computer - CrashPlan Support`_

.. _`Using CrashPlan On A Headless Computer - CrashPlan Support`:
    https://support.crashplan.com/Configuring/Using_CrashPlan_On_A_Headless_Computer


License
-------

.. image:: https://img.shields.io/github/license/TimZehta/dullaplan.svg
    :alt: badge: GitHub license (MIT)
    :align: right
    :target: `MIT License`_
- `<LICENSE>`_ (`MIT License`_)

.. _`MIT License`: http://www.opensource.org/licenses/MIT
