# 🐧 Linux User & Group Management

A hands-on Linux administration project focused on user and group management, directory permissions, Access Control Lists (ACLs), Bash scripting, and scheduled automation.

The project demonstrates practical Linux system administration skills relevant to DevOps and Cloud Operations.

## 📌 Project Overview

This project implements a shared Linux environment where multiple users access common directories through group-based permissions and ACLs.

A Bash automation script generates reports about Linux users, group memberships, and directory permissions. The script also maintains execution logs and can be scheduled using Cron.

### 🎯 Objectives

* Create and manage Linux users and groups.
* Configure group-based access control.
* Apply Linux file and directory permissions.
* Implement Access Control Lists (ACLs).
* Automate user and group reporting with Bash.
* Schedule recurring tasks using Cron.
* Maintain project documentation and version control with Git and GitHub.

## 🛠️ Technologies Used

| Technology           | Purpose                                         |
| -------------------- | ----------------------------------------------- |
| Ubuntu Linux         | Operating system and administration environment |
| Bash                 | Shell scripting and automation                  |
| Linux Users & Groups | Account and group management                    |
| File Permissions     | Access control using `chmod` and `chown`        |
| ACL                  | Fine-grained access permissions                 |
| Cron                 | Scheduled task automation                       |
| Git                  | Version control                                 |
| GitHub               | Project hosting and documentation               |

## 🏗️ Project Architecture

```text
linux-user-management/
│
├── README.md
├── .gitignore
│
├── scripts/
│   └── user_group_report.sh
│
└── screenshots/
    ├── 01-user-group-list.png
    ├── 02-directory-permissions.png
    ├── 03-acl-permissions.png
    ├── 04-automation-script.png
    └── 05-github-project.png
```

### Shared Directory Structure

```text
/srv/linux-user-management/
│
├── logs/
│   ├── user_group_report.log
│   └── cron.log
│
├── reports/
│   └── user_group_report.txt
│
└── scripts/
```

The project keeps its scripts, generated reports, and operational logs organized in separate directories.

## 👥 User and Group Management

### Group Configuration

A Linux group named `devops` is used to manage shared access.

| Account      | Purpose             | Group Membership               |
| ------------ | ------------------- | ------------------------------ |
| `developer1` | Development user    | Own primary group and `devops` |
| `developer2` | Development user    | Own primary group and `devops` |
| `devops`     | Shared access group | Provides group-based access    |

### Create the Group

```bash
sudo groupadd devops
```

### Create Development Users

```bash
sudo useradd -m developer1
sudo useradd -m developer2
```

### Add Users to the DevOps Group

```bash
sudo usermod -aG devops developer1
sudo usermod -aG devops developer2
```

### Verify Group Memberships

```bash
getent group devops
id developer1
id developer2
```

These commands verify the group configuration and the users' supplementary group memberships.

> Note: The commands above illustrate the setup procedure. Skip account creation if the users or group already exist.

## 🔐 Directory Permissions

The shared project directory uses ownership and Linux permissions to control access.

| Directory                            | Permission | Purpose                         |
| ------------------------------------ | ---------- | ------------------------------- |
| `/srv/linux-user-management`         | `750`      | Owner and group access          |
| `/srv/linux-user-management/logs`    | `2770`     | Shared group access with setgid |
| `/srv/linux-user-management/reports` | `2770`     | Shared group access with setgid |
| `/srv/linux-user-management/scripts` | `750`      | Controlled script access        |

### Configure Ownership

```bash
sudo chown -R rafeekahamed:devops /srv/linux-user-management
```

### Configure Directory Permissions

```bash
sudo chmod 750 /srv/linux-user-management
sudo chmod 2770 /srv/linux-user-management/logs
sudo chmod 2770 /srv/linux-user-management/reports
sudo chmod 750 /srv/linux-user-management/scripts
```

### Verify Permissions

```bash
ls -ld /srv/linux-user-management
ls -ld /srv/linux-user-management/logs
ls -ld /srv/linux-user-management/reports
ls -ld /srv/linux-user-management/scripts
```

The setgid bit (`2`) on the shared directories helps new files and subdirectories inherit the directory's group.

## 🛡️ Access Control Lists (ACL)

ACLs provide additional control over file and directory access.

The project uses ACLs to configure shared access to the logs directory.

### Install ACL Utilities

```bash
sudo apt update
sudo apt install acl
```

### Configure ACL Permissions

```bash
sudo setfacl -m g:devops:rwx /srv/linux-user-management/logs
sudo setfacl -d -m g:devops:rwx /srv/linux-user-management/logs
```

The first command grants the `devops` group read, write, and execute permissions on the directory. The second configures default ACL permissions for newly created items, subject to normal permission-mask and application behavior.

### Verify ACL Configuration

```bash
getfacl /srv/linux-user-management/logs
```

This helps verify the directory's access rules and default ACL entries.

## ⚙️ Bash Automation

The project includes an automated reporting script:

```text
scripts/user_group_report.sh
```

The script is designed to:

* Check the required group and directory configuration.
* Collect Linux user and group information.
* Report user membership details.
* Display shared directory permissions.
* Generate a report file.
* Record execution results in a log.
* Handle errors and report failures.

### Run the Script

```bash
bash ~/linux-user-management/scripts/user_group_report.sh
```

Alternatively, execute it directly if it has executable permissions:

```bash
~/linux-user-management/scripts/user_group_report.sh
```

### Check the Generated Report

```bash
cat /srv/linux-user-management/reports/user_group_report.txt
```

### Check the Execution Log

```bash
tail -n 20 /srv/linux-user-management/logs/user_group_report.log
```

### Validate Bash Syntax

```bash
bash -n ~/linux-user-management/scripts/user_group_report.sh
```

No output from `bash -n` normally indicates that no Bash syntax errors were detected.

## ⏰ Scheduled Automation with Cron

Cron can run the reporting script automatically at a scheduled time.

### Edit the User Crontab

```bash
crontab -e
```

Example daily schedule:

```cron
30 3 * * * /home/rafeekahamed/linux-user-management/scripts/user_group_report.sh >> /srv/linux-user-management/logs/cron.log 2>&1
```

This entry schedules the script for **03:30 UTC**, which corresponds to **09:00 IST**, when the system's Cron service uses UTC.

### Verify the Crontab

```bash
crontab -l
```

### Check Cron Logs

```bash
tail -n 20 /srv/linux-user-management/logs/cron.log
```

> **Environment note:** On WSL, scheduled jobs run only while the relevant Linux environment and Cron service are running. Confirm the system timezone and Cron service status before relying on the schedule.

## 📸 Project Screenshots

Screenshots documenting the project are available in the [`screenshots/`](screenshots/) directory.

| Screenshot            | Description                                |
| --------------------- | ------------------------------------------ |
| User and Group List   | Linux user and group configuration         |
| Directory Permissions | Shared directory ownership and permissions |
| ACL Permissions       | Access Control List configuration          |
| Automation Script     | Report generation and execution results    |
| GitHub Repository     | Project repository and documentation       |

## 🧪 Verification Commands

Use the following commands to inspect the configuration.

```bash
id developer1
id developer2
```

```bash
getent group devops
```

```bash
ls -ld /srv/linux-user-management/*
```

```bash
getfacl /srv/linux-user-management/logs
```

```bash
cat /srv/linux-user-management/reports/user_group_report.txt
```

These checks help verify account memberships, directory permissions, ACL entries, and report generation.

## 🔑 Key Learning Outcomes

Through this project, I practised:

* Linux user and group administration.
* Group-based access control.
* File ownership and permission management.
* ACL configuration and verification.
* Bash scripting and error handling.
* Automated report generation.
* Cron-based task scheduling.
* Git version control and GitHub documentation.
* Organizing operational logs and reports.

## 🚀 Future Improvements

Potential extensions include:

* Disk usage and system resource monitoring.
* Automated alerts for failed scripts.
* Log rotation and retention policies.
* More comprehensive permission validation.
* CI checks for Bash scripts.
* Automated project setup using an installation script.

## 👨‍💻 Author

**Rafeek Ahamed M.**

Aspiring DevOps Engineer | Azure Cloud Engineer

* GitHub: [RafeekAhamed](https://github.com/RafeekAhamed)
* LinkedIn: [Rafeek Ahamed](https://www.linkedin.com/in/rafeek-ahamed-devops/)

---

*This project was built as a hands-on exercise to strengthen Linux administration, access control, scripting, and automation skills for DevOps and Cloud Operations.*
