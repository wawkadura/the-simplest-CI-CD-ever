# The Simplest CI/CD Ever

This repository contains a script for automating CI/CD processes for multiple projects. The script checks for changes in specified Git repositories, pulls updates, and executes a series of commands for each service.

## Repository Structure

```
CICD/
├── auto_deploy.log [will be created automatically]
├── auto_deploy.sh
└── services.json
```

- **auto_deploy.sh**: The main script that performs the CI/CD tasks.
- **auto_deploy.log**: Log file where the script logs its output.
- **services.json**: JSON configuration file specifying the services to monitor and the commands to run.

## Requirements

The script requires the following tools to be installed:

- `jq`: Command-line JSON processor.
- `git`: Version control system.
- `tee`: Reads from standard input and writes to standard output and files.

You can install these tools using the following commands on a Debian-based system:

```bash
sudo apt-get update
sudo apt-get install jq git coreutils
```

## Configuration

### services.json

The `services.json` file should contain an array of service objects, each specifying:

- `dir`: The directory of the repository.
- `branch`: The branch to monitor.
- `service_name`: A name for the service.
- `commands`: An array of commands to run when changes are detected.
- `detailedLogs`: Boolean indicating whether to output detailed logs for the commands.

Example `services.json`:

```json
[
  {
    "dir": "/home/ubuntu/monitor-app",
    "branch": "main",
    "service_name": "monitor-app",
    "commands": [
      "npm i",
      "npm build",
      "sudo systemctl restart monitor-app.service"
    ],
    "detailedLogs": true
  },
  {
    "dir": "/home/ubuntu/cool-app",
    "branch": "develop",
    "service_name": "cool-app",
    "commands": ["npm i", "npm build", "forever restart cool-app"],
    "detailedLogs": true
  }
]
```

## Usage

Make the `auto_deploy.sh` script executable:

```bash
chmod +x auto_deploy.sh
```

To run the script manually:

```bash
./auto_deploy.sh
```

To automate the script using crontab, add the following line to your crontab file:

```bash
* * * * * /path/to/cicd/folder/auto_deploy.sh
```

This will execute the script every minute.
