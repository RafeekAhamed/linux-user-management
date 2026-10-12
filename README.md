# Linux User & Group Management

A hands-on Linux administration project demonstrating user and group
management, directory permissions, Access Control Lists (ACLs), Bash
automation, report generation, and scheduled execution with cron.

> **Project focus:** Linux system administration, least-privilege access
> control, operational scripting, and task scheduling.

## Table of Contents

-   [Project Overview](#project-overview)
-   [Objectives](#objectives)
-   [Technologies Used](#technologies-used)
-   [Architecture and Directory
    Layout](#architecture-and-directory-layout)
-   [Prerequisites](#prerequisites)
-   [Setup Instructions](#setup-instructions)
-   [User and Group Management](#user-and-group-management)
-   [Directory Permissions](#directory-permissions)
-   [Access Control Lists (ACLs)](#access-control-lists-acls)
-   [Bash Automation and Reporting](#bash-automation-and-reporting)
-   [Scheduled Automation with Cron](#scheduled-automation-with-cron)
-   [Verification Checklist](#verification-checklist)
-   [Troubleshooting](#troubleshooting)
-   [Screenshots](#screenshots)
-   [Key Learning Outcomes](#key-learning-outcomes)
-   [Future Improvements](#future-improvements)
-   [Author](#author)

## Project Overview

This project creates a shared Linux workspace for a small development
team. Two development users, `developer1` and `developer2`, are assigned
to the `devops` group. Shared directories are configured with controlled
permissions and ACLs. A Bash script collects user, group, directory, and
log-file information into a report. Cron is configured to run the report
script daily.

The project is intended for learning and portfolio demonstration.
Commands that create users, change ownership, configure ACLs, or modify
system directories require appropriate administrative privileges.

## Objectives

-   Create and manage Linux users and groups.
-   Configure directory ownership and permissions.
-   Apply and inspect POSIX ACLs for shared access.
-   Use a Bash script to generate a system administration report.
-   Schedule recurring automation with cron.
-   Validate access by testing authorized and unauthorized users.
-   Document the setup, expected results, and troubleshooting process.

## Technologies Used

| Technology | Purpose |
|---|---|
| Linux / Ubuntu | Operating system and administration environment |
| Bash | Automation and report generation |
| `useradd`, `usermod`, `id`, `getent` | User and group administration |
| `chmod`, `chown`, `ls` | Ownership and standard permissions |
| `getfacl`, `setfacl` | ACL inspection and configuration |
| Cron | Scheduled execution |
| Git and GitHub | Version control and project documentation |

## Architecture and Directory Layout

The working directory used by the script is
`/srv/linux-user-management`; the repository is expected at
`~/linux-user-management`.

``` text
/srv/linux-user-management/
├── logs/
│   ├── cron.log
│   └── user_group_report.log
├── reports/
│   └── user_group_report.txt
└── scripts/
    └── user_group_report.sh
```

The Git repository contains the script, README, screenshots, and
`.gitignore`:

``` text
linux-user-management/
├── scripts/
│   └── user_group_report.sh
├── screenshots/
├── README.md
└── .gitignore
```

Generated logs and temporary test artifacts should not be committed
unless they are deliberately sanitized and included as documentation
samples.

## Prerequisites

-   Ubuntu or another Linux distribution using cron and standard POSIX
    permissions.
-   A user with `sudo` privileges.
-   `bash`, `cron`, and Git.
-   ACL utilities (`getfacl` and `setfacl`), typically provided by the
    `acl` package.
-   Optional: `tree` for a visual directory listing.

Install required packages on Ubuntu/Debian:

``` bash
sudo apt update
sudo apt install -y cron acl git
```

Check the available commands:

``` bash
bash --version
crontab -l
getfacl --version
```

## Setup Instructions

### 1. Clone the repository

``` bash
git clone https://github.com/RafeekAhamed/linux-user-management.git
cd linux-user-management
```

If the repository is already cloned, update it instead:

``` bash
git pull origin main
```

### 2. Create the team group and users

Check first to avoid recreating existing accounts:

``` bash
getent group devops
id developer1
id developer2
```

If the group does not exist:

``` bash
sudo groupadd devops
```

If either user does not exist, create it:

``` bash
sudo useradd -m developer1
sudo useradd -m developer2
```

Add the users to the group:

``` bash
sudo usermod -aG devops developer1
sudo usermod -aG devops developer2
```

Verify:

``` bash
getent group devops
id developer1
id developer2
```

Expected result: both accounts should list `devops` among their
supplementary groups. Existing users may need to start a new login
session for group membership to be reflected in their sessions.

### 3. Create the project directories

``` bash
sudo mkdir -p /srv/linux-user-management/{logs,reports,scripts}
```

Copy the script from the repository:

``` bash
sudo cp scripts/user_group_report.sh /srv/linux-user-management/scripts/
```

Set ownership and baseline permissions:

``` bash
sudo chown -R "$USER":devops /srv/linux-user-management
sudo chmod 750 /srv/linux-user-management
sudo chmod 2770 /srv/linux-user-management/logs
sudo chmod 2770 /srv/linux-user-management/reports
sudo chmod 750 /srv/linux-user-management/scripts
sudo chmod +x /srv/linux-user-management/scripts/user_group_report.sh
```

The setgid bit (`2` in `2770`) on the shared logs and reports
directories makes new entries inherit the directory's group on typical
Linux filesystems. Confirm the resulting ownership and permissions with
`ls -ld`.

> **Note:** These commands establish a reference setup. If your existing
> script, directory layout, or ACL policy differs, review the current
> configuration before applying recursive ownership or permission
> changes.

### 4. Configure ACLs

Install ACL utilities if needed:

``` bash
sudo apt install -y acl
```

Set the group ACL on the shared logs directory and default ACLs for
newly created entries:

``` bash
sudo setfacl -m g:devops:rwx /srv/linux-user-management/logs
sudo setfacl -d -m g:devops:rwx /srv/linux-user-management/logs
```

Inspect the result:

``` bash
getfacl /srv/linux-user-management/logs
```

The effective access depends on the ACL mask and permissions on every
parent directory. `other::---` can deny access to users who do not match
the owner or an applicable group/named ACL entry.

### 5. Make the script executable and run it

``` bash
chmod +x scripts/user_group_report.sh
/home/rafeekahamed/linux-user-management/scripts/user_group_report.sh
```

If your home directory or repository is different, use the actual
absolute path to the script. The project script is expected to save its
report to:

`/srv/linux-user-management/reports/user_group_report.txt`

and its execution log to:

`/srv/linux-user-management/logs/user_group_report.log`

## User and Group Management

The project uses the following test identities:

| Account | Purpose | Group |
|---|---|---|
| `developer1` | Development account and ACL write test | `devops` |
| `developer2` | Development account and ACL read test | `devops` |
| `acltester` | Temporary unauthorized-access test account | Not a member of `devops` |

Useful commands:

``` bash
getent passwd developer1
getent passwd developer2
getent group devops
id developer1
id developer2
```

Do not create a duplicate user if the account already exists. The
`acltester` account should be created only for the test and removed
afterward.

## Directory Permissions

Inspect the main project paths:

``` bash
ls -ld /srv/linux-user-management
ls -ld /srv/linux-user-management/logs
ls -ld /srv/linux-user-management/reports
ls -ld /srv/linux-user-management/scripts
```

Example reference policy:

  -----------------------------------------------------------------------------------------
  Path                                                   Example mode Purpose
  -------------------------------------- ---------------------------- ---------------------
  `/srv/linux-user-management`                                  `750` Restrict traversal to
                                                                      owner and group

  `/srv/linux-user-management/logs`                   `2770` plus ACL Shared group access
                                                                      with setgid

  `/srv/linux-user-management/reports`                         `2770` Shared group access
                                                                      with setgid

  `/srv/linux-user-management/scripts`                          `750` Limit
                                                                      script-directory
                                                                      access
  -----------------------------------------------------------------------------------------

The exact mode may differ depending on the ACL mask and your chosen
access policy. Verify actual permissions instead of assuming that they
match this table.

Permission reference:

- `r` = read.
- `w` = write.
- `x` = execute; on directories, it also permits traversal.
- `2` in a directory mode such as `2770` enables setgid.

## Access Control Lists (ACLs)

ACLs provide more granular permissions than the standard
owner/group/other mode bits.

### Inspect ACLs

``` bash
getfacl /srv/linux-user-management/logs
```

### Test authorized access

Create a temporary test file:

``` bash
sudo touch /srv/linux-user-management/logs/acl_demo.txt
sudo chown "$USER":devops /srv/linux-user-management/logs/acl_demo.txt
sudo chmod 660 /srv/linux-user-management/logs/acl_demo.txt
sudo setfacl -m g:devops:rw- /srv/linux-user-management/logs/acl_demo.txt
```

Test write access as `developer1` and read access as `developer2`:

``` bash
sudo -u developer1 bash -c 'echo "Authorized write successful" >> /srv/linux-user-management/logs/acl_demo.txt'
sudo -u developer2 cat /srv/linux-user-management/logs/acl_demo.txt
```

Expected output:

``` text
Authorized write successful
```

### Test unauthorized access

Make sure `acltester` exists and is not a member of `devops`:

``` bash
id acltester
groups acltester
```

If the test account does not exist, create it:

``` bash
sudo useradd -m acltester
```

Attempt to read and write the test file:

``` bash
sudo -u acltester cat /srv/linux-user-management/logs/acl_demo.txt
sudo -u acltester bash -c 'echo "Unauthorized write" >> /srv/linux-user-management/logs/acl_demo.txt'
```

Expected result: both operations fail with `Permission denied`, provided
that `acltester` is not granted access through another ACL or group and
can traverse the parent directories.

Clean up the test artifacts:

``` bash
sudo rm -f /srv/linux-user-management/logs/acl_demo.txt
sudo userdel -r acltester
```

If `acltester` was an existing account, do not delete it; use a
different temporary test identity instead.

## Bash Automation and Reporting

The script `scripts/user_group_report.sh` gathers user/group and
directory/log information and writes a text report to:

``` text
/srv/linux-user-management/reports/user_group_report.txt
```

Execution messages are written to:

``` text
/srv/linux-user-management/logs/user_group_report.log
```

### Run the script

``` bash
/home/rafeekahamed/linux-user-management/scripts/user_group_report.sh
```

### Validate Bash syntax

From the repository root:

``` bash
bash -n scripts/user_group_report.sh
echo $?
```

Expected result: exit code `0` indicates that Bash found no syntax
errors.

### Inspect the report and log

``` bash
tail -n 20 /srv/linux-user-management/reports/user_group_report.txt
tail -n 20 /srv/linux-user-management/logs/user_group_report.log
stat /srv/linux-user-management/reports/user_group_report.txt
```

A successful run should include a message similar to:

``` text
SUCCESS: Report saved to /srv/linux-user-management/reports/user_group_report.txt
```

The report reflects the information collected at the time the script
ran. Run the script again to refresh it after relevant system changes.

## Scheduled Automation with Cron

The intended user-crontab schedule is to run the report every day at
03:30 according to the system's configured timezone. Confirm the live
configuration with `crontab -l` before relying on this schedule.

### Current cron entry

``` cron
30 3 * * * /home/rafeekahamed/linux-user-management/scripts/user_group_report.sh >> /srv/linux-user-management/logs/cron.log 2>&1
```

Cron field order is minute, hour, day of month, month, and day of week.
`30 3 * * *` means every day at 03:30.

### Verify cron is enabled and running

``` bash
sudo service cron status
```

Expected status includes:

``` text
Active: active (running)
```

### Verify the schedule

``` bash
crontab -l
```

Keep only the intended production schedule. Remove temporary test
entries such as a command running every minute after testing is
complete.

### Review cron output

``` bash
tail -n 20 /srv/linux-user-management/logs/cron.log
```

The script also writes its own execution log:

``` bash
tail -n 20 /srv/linux-user-management/logs/user_group_report.log
```

The cron redirection log captures standard output and standard error
from the scheduled command; the script's own log records the script's
internal execution messages. The cron log may be empty until the next
scheduled run if it was recently recreated.

### Test the command without waiting for the scheduled time

``` bash
/home/rafeekahamed/linux-user-management/scripts/user_group_report.sh >> /srv/linux-user-management/logs/cron.log 2>&1
```

This checks the command and redirection manually. It does **not** prove
that cron triggered the command. To verify a scheduled execution,
correlate cron service/system logs with a report modification time or a
timestamped script log entry at the scheduled time.

On systems using systemd, recent cron activity can also be checked with:

``` bash
sudo journalctl -u cron --since today
```

## Verification Checklist

Run these checks from the repository root:

``` bash
# Repository state
git status

# Users and group
id developer1
id developer2
getent group devops

# Directory permissions
ls -ld /srv/linux-user-management
ls -ld /srv/linux-user-management/logs
ls -ld /srv/linux-user-management/reports
ls -ld /srv/linux-user-management/scripts

# ACL
getfacl /srv/linux-user-management/logs

# Bash syntax
bash -n scripts/user_group_report.sh

# Cron service and schedule
sudo service cron status
crontab -l

# Generated report and execution log
stat /srv/linux-user-management/reports/user_group_report.txt
tail -n 10 /srv/linux-user-management/logs/user_group_report.log
```

Before publishing, ensure that the report script runs successfully, the
expected users and group exist, authorized/unauthorized ACL tests behave
as expected, and no temporary test job remains in the crontab.

## Troubleshooting

### Cron service is inactive

``` bash
sudo service cron status
sudo service cron start
sudo systemctl enable cron
```

### The report script does not execute

``` bash
ls -l scripts/user_group_report.sh
bash -n scripts/user_group_report.sh
```

If needed, restore executable permission:

``` bash
chmod +x scripts/user_group_report.sh
```

Confirm that the absolute script path in `crontab -l` exists and is
executable by the crontab owner. Cron jobs should use absolute paths.

### Permission denied when writing logs or reports

``` bash
namei -l /srv/linux-user-management/logs
ls -ld /srv/linux-user-management/logs
getfacl /srv/linux-user-management/logs
```

Check ownership, parent-directory traversal permissions, ACL entries,
and ACL masks before changing permissions. Avoid using `chmod 777` as a
workaround.

### Cron log contains old errors

Inspect the log and distinguish historical messages from recent
executions:

``` bash
tail -n 30 /srv/linux-user-management/logs/cron.log
sudo journalctl -u cron --since today
```

If archiving the old log, preserve it as historical evidence and create
a new log with suitable ownership and permissions. Do not describe
manual script output as a cron-triggered execution.

### ACL test does not behave as expected

``` bash
id developer1
id developer2
id acltester
getfacl /srv/linux-user-management/logs/acl_demo.txt
namei -l /srv/linux-user-management/logs/acl_demo.txt
```

Check group membership, ACL masks, named ACL entries, and traversal
permissions on every parent directory.

## Screenshots

Store evidence images in the repository's `screenshots/` directory. Use
the filenames below only when the corresponding image actually exists.

| Suggested filename | Evidence |
|---|---|
| `01-user-group-management.png` | User accounts and `devops` group membership |
| `02-directory-permissions.png` | Directory ownership and mode bits |
| `03-acl-configuration.png` | `getfacl` output |
| `04-automated-report.png` | Generated report and success log |
| `05-acl-unauthorized-access.png` | Unauthorized access denied |
| `06-github-project.png` | GitHub repository and README |

For ACL evidence, remove test accounts and files after capturing
screenshots. Never include passwords, access tokens, private keys, or
other secrets in screenshots. Keep only screenshot files that actually
exist in the repository, and update this table if filenames change.

## Key Learning Outcomes

-   Linux account and group administration.
-   File and directory ownership, standard permissions, and setgid.
-   POSIX ACL configuration and least-privilege access validation.
-   Bash scripting, syntax checks, logging, and report generation.
-   Cron scheduling and execution troubleshooting.
-   Git-based documentation and evidence-driven project verification.

## Future Improvements

-   Add unit-style tests for script output and error conditions.
-   Add log rotation for generated logs.
-   Add configurable report paths and user/group lists.
-   Add structured output such as CSV or JSON.
-   Add automated validation through a CI workflow.
-   Add sanitized sample reports and clearer operational runbooks.

## Author

**Rafeek Ahamed M.**

-   GitHub: [RafeekAhamed](https://github.com/RafeekAhamed)
-   LinkedIn: [Rafeek
    Ahamed](https://www.linkedin.com/in/rafeek-ahamed-devops/)

------------------------------------------------------------------------

*This documentation describes a learning project. Verify paths, account
names, permissions, and timezone on your own system before applying
commands in a production environment.*
