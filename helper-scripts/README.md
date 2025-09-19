# Helper Scripts

This folder contains utility scripts for development, testing, and troubleshooting.

## Scripts Overview

### 🔧 **fetch-sha-no-git.bat**
- **Purpose:** Fetch Git commit SHA from GitHub API without Git installed
- **Use Case:** When deploying from ZIP files without Git
- **How to run:** `fetch-sha-no-git.bat`
- **What it does:** 
  - Connects to GitHub API to get latest commit info
  - Demonstrates multiple methods (PowerShell, curl, WebClient)
  - Provides fallback values if API fails

### 🔧 **get-git-sha.bat**
- **Purpose:** Demonstrate various Git SHA extraction methods
- **Use Case:** Understanding how Git information is extracted locally
- **How to run:** `get-git-sha.bat` (requires Git repository)
- **What it does:**
  - Shows different `git` commands for extracting SHA, branch, author, etc.
  - Educational/reference tool for Git information extraction
  - Displays deployment variables that would be set

### 🧪 **test-iis-commands.ps1**
- **Purpose:** Test IIS PowerShell commands before deployment
- **Use Case:** Troubleshooting IIS deployment issues
- **How to run:** `.\test-iis-commands.ps1` (as Administrator in PowerShell)
- **What it does:**
  - Verifies WebAdministration module loads
  - Tests Get-WebAppPool, Get-Website, Stop-WebAppPool commands
  - Checks if SimpleIISApp already exists in IIS
  - Helps diagnose IIS configuration problems

## When to Use These Scripts

- **Having deployment issues?** → Run `test-iis-commands.ps1`
- **Want to understand Git integration?** → Check `get-git-sha.bat`
- **Deploying without Git?** → Reference `fetch-sha-no-git.bat`

## Main Deployment Script

The main deployment script is in the parent directory:
- **`../deploy-run-as-admin.bat`** - Main deployment script (run as Administrator)
