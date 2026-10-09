# Linux User & Group Management Project

## Project Overview

This project demonstrates Linux user and group administration, shared directory management, file permissions, Access Control Lists (ACLs), Bash scripting, logging, report generation, and automated scheduling using cron.

The project is configured in Ubuntu running on WSL2.

## Objectives

* Create and manage Linux users.
* Create groups and assign users to groups.
* Configure shared directories.
* Manage file and directory permissions.
* Implement collaborative access using SGID and ACLs.
* Develop a Bash script to generate user and group reports.
* Maintain execution logs.
* Schedule automated report generation using cron.

## Technologies Used

* Ubuntu Linux
* WSL2
* Bash scripting
* Linux user and group management
* File permissions: `chmod`, `chown`
* Access Control Lists: `getfacl`, `setfacl`
* Scheduling: `cron`
* Logging and report generation

## Users and Groups

### Group

* Group name: `devops`

### Users

| Username   | Primary Group | Supplementary Group |
| ---------- | ------------- | ------------------- |
| developer1 | developer1    | devops              |
| developer2 | developer2    | devops              |

Both developer accounts belong to the `devops` group to support shared project access.

## Project Directory Structure

```text
linux-user-management/
├── README.md
├── logs/
├── reports/
└── scripts/
    └── user_group_report.sh
```

Shared system directories:

```text
/srv/linux-user-management/
├── logs/
│   ├── shared_test.log
│   ├── user_group_report.log
│   └── cron.log
├── reports/
│   └── user_group_report.txt
└── scripts/
    └── user_group_report.sh
```

## Implementation

### 1. Create the DevOps Group

```bash
sudo groupadd devops
```

### 2. Create Developer Accounts

```bash
sudo useradd -m -s /bin/bash developer1
sudo useradd -m -s /bin/bash developer2
```

### 3. Add Users to the DevOps Group

```bash
sudo usermod -aG devops developer1
sudo usermod -aG devops developer2
```

### 4. Verify User and Group Membership

```bash
id developer1
id developer2
getent group devops
```

### 5. Create Shared Project Directories

```bash
sudo mkdir -p /srv/linux-user-management/{logs,reports,scripts}
```

### 6. Configure Ownership and Permissions

```bash
sudo chown -R rafeekahamed:devops /srv/linux-user-management
sudo chmod 750 /srv/linux-user-management
sudo chmod 2770 /srv/linux-user-management/logs
sudo chmod 2770 /srv/linux-user-management/reports
sudo chmod 750 /srv/linux-user-management/scripts
```

The SGID bit on the shared directories helps new files inherit the directory's group.

### 7. Configure ACLs

```bash
sudo setfacl -m g:devops:rwx /srv/linux-user-management/logs
sudo setfacl -d -m g:devops:rwx /srv/linux-user-management/logs
sudo setfacl -d -m o::--- /srv/linux-user-management/logs
```

Verify ACL configuration:

```bash
getfacl /srv/linux-user-management/logs
```

### 8. Test Shared Access

Create a file as `developer1`:

```bash
sudo -u developer1 bash -c 'echo "Log created by developer1" > /srv/linux-user-management/logs/shared_test.log'
```

Read the file as `developer2`:

```bash
sudo -u developer2 cat /srv/linux-user-management/logs/shared_test.log
```

Expected output:

```text
Log created by developer1
```

### 9. Generate a User and Group Report

The Bash script collects user information, group membership, account details, and shared directory permissions.

Run the script:

```bash
/home/rafeekahamed/linux-user-management/scripts/user_group_report.sh
```

Generated report:

```text
/srv/linux-user-management/reports/user_group_report.txt
```

Execution log:

```text
/srv/linux-user-management/logs/user_group_report.log
```

### 10. Schedule Automated Reports

The report script is configured to run daily at 03:30 UTC, equivalent to 09:00 IST.

View the current cron configuration:

```bash
crontab -l
```

Configured schedule:

```cron
30 3 * * * /home/rafeekahamed/linux-user-management/scripts/user_group_report.sh >> /srv/linux-user-management/logs/cron.log 2>&1
```

Cron runs the scheduled task only while the relevant Linux environment and cron service are running.

### 11. Verify the Report

```bash
cat /srv/linux-user-management/reports/user_group_report.txt
```

Verify the execution logs:

```bash
cat /srv/linux-user-management/logs/user_group_report.log
cat /srv/linux-user-management/logs/cron.log
```

## Key Learning Outcomes

* Linux account and group administration.
* Primary and supplementary group management.
* Linux file ownership and permission modes.
* SGID directory permissions.
* ACL configuration and inheritance.
* Bash scripting and error handling.
* User and group report generation.
* Log file management.
* Cron-based task scheduling.

## Future Enhancements

* Add user creation and deletion automation.
* Implement automated permission validation.
* Add disk usage monitoring.
* Introduce log rotation.
* Add automated project verification tests.
* Publish the project source code on GitHub.

## Project Status

Core user and group configuration, shared log access, report generation, and cron scheduling have been configured. Continue validating scheduled report execution and documenting the final results.

---

**Project:** Linux User & Group Management
**Environment:** Ubuntu Linux on WSL2
**Focus:** Linux Administration, Bash Scripting, Permissions, ACLs, and Automation
