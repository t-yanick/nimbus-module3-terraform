### VS Code integrated terminal doesn't pick up PATH changes immediately

**Problem**: After adding Terraform's install path to `~/.bashrc` and 
running `source ~/.bashrc`, `terraform version` still returned 
"command not found" in VS Code's integrated Git Bash terminal.

**Root cause**: VS Code's integrated terminal inherits PATH from VS Code's 
own process (launched before the PATH change). Running `source ~/.bashrc` 
in an existing terminal tab doesn't fully propagate to all subshell 
behaviors in VS Code's integrated terminal.

**Resolution**: Closed the terminal tab (trash icon) and opened a new one 
with Ctrl+`. The new terminal spawned fresh and read `.bashrc` correctly.

**Lesson**: After editing `.bashrc`, "source" works in standalone Git Bash 
windows but NOT reliably in VS Code's integrated terminal. For VS Code, 
always close and reopen the terminal tab after any PATH change. Nuclear 
option: restart VS Code entirely.

### Why can't I install Azure CLI directly in Git Bash?

**Question**: Why doesn't `apt install azure-cli` or similar work in Git Bash?

**Answer**: Git Bash is a terminal emulator + bash shell + MinGW utilities 
layered on top of Windows. It is NOT a Linux OS — just a translation layer. 
It has no package manager (`apt`, `yum`, `brew`). Installing applications 
is still a Windows OS task that needs Windows-native tools (winget, MSI 
installer, or Chocolatey).

**Three options to install Azure CLI on Windows:**
1. `winget install -e --id Microsoft.AzureCLI` (from PowerShell) — recommended
2. `pip install --upgrade azure-cli` (from Git Bash, if Python is installed) — works
3. Download MSI from docs.microsoft.com

**Longer-term option for serious Linux-on-Windows work:**
WSL2 with Ubuntu provides a real Linux kernel inside Windows. Then 
`apt install azure-cli` works for real. Add to backlog for after Module 3.

**Lesson**: The "feels like Linux" tools on Windows (Git Bash, 
PowerShell with WSL interop) are compromises. For heavy DevOps/Linux work, 
graduate to WSL2 or an actual Linux VM.