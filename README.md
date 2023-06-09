# check-please
A shell script that runs chkrootkit, rkhunter, and ClamAV with some others depending on the OS.

# Usage:
./checkme.sh or ./checkme.sh -h for homedir or ./checkme.sh -s for full system scan


# Dependencies for MacOS:
- `chkrootkit` brew install chkrootkit
- `rkhunter` brew install rkhunter
- `ClamAV` brew install clamav
- `Lynis` brew install lynis

# Dependencies for Debian-based distributions:
- `chkrootkit` apt install chkrootkit
- `rkhunter` apt install rkhunter
- `ClamAV` apt install clamav
- `Unhide` apt install unhide
- `debsums` apt install debsums
- `Lynis` apt install lynis


# Config files
Line Number 940 in  /usr/local/etc/rkhunter.conf
If on MacOS you will want to change the default which is /dev/shm even if not uncommented.

Here is mine on MacOS:
```bash
 940 #SUSPSCAN_TEMP=/dev/shm
 941 SUSPSCAN_TEMP=/Users/klarsen/tmp
 ```


# Example Usage and output:
```bash
% ./checkme.sh
 Running chkrootkit [+]
Password:
not infected
not infected
not infected
not infected
not infected
not infected
 Running rkhunter  [+]
[ Rootkit Hunter version 1.4.6 ]

Checking rkhunter data files...
  Checking file mirrors.dat                                  [ No update ]
  Checking file programs_bad.dat                             [ No update ]
  Checking file backdoorports.dat                            [ No update ]
  Checking file suspscan.dat                                 [ No update ]
  Checking file i18n/cn                                      [ No update ]
  Checking file i18n/de                                      [ No update ]
  Checking file i18n/en                                      [ No update ]
  Checking file i18n/tr                                      [ No update ]
  Checking file i18n/tr.utf8                                 [ No update ]
  Checking file i18n/zh                                      [ No update ]
  Checking file i18n/zh.utf8                                 [ No update ]
  Checking file i18n/ja                                      [ No update ]
[ Rootkit Hunter version 1.4.6 ]
File updated: searched for 169 files, found 97
Warning: The command '/usr/bin/fuser' has been replaced by a script: /usr/bin/fuser: Perl script text executable
Warning: The command '/usr/bin/whatis' has been replaced by a script: /usr/bin/whatis: POSIX shell script text executable, ASCII text
Warning: The command '/usr/bin/shasum' has been replaced by a script: /usr/bin/shasum: Perl script text executable
Warning: Checking for possible rootkit strings    [ Warning ]
Warning: No system startup files found.
Warning: The SSH configuration option 'PermitRootLogin' has not been set.
         The default value may be 'yes', to allow root access.
Warning: The SSH configuration option 'Protocol' has not been set.
         The default value may be '2,1', to allow the use of protocol version 1.
Warning: Hidden file found: /usr/share/man/man5/.rhosts.5: troff or preprocessor input text, ASCII text
 Running a lynis audit scan  [+]
[+] Software: Malware
  - Checking chkrootkit                                       [ FOUND ]
  - Checking Rootkit Hunter                                   [ FOUND ]
  - Checking ClamAV scanner                                   [ FOUND ]
  - Malware software components                               [ FOUND ]
    - Rootkit scanner                                         [ FOUND ]
    - Installed malware scanner                               [ FOUND ]
  - Malware scanner        [V]
 Usage: ./checkme.sh -h for homedir clamscan or ./checkme.sh -s for full system clamscan
```