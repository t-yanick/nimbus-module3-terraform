# Terraform on Azure — First IaC Deployment

> Nimbus Compute Academy — Module 3 Lesson 1 · October 2026

My first production-style Terraform deployment: a `providers.tf` + `main.tf` pair that provisions a real Azure Resource Group in **South Africa North** via the HashiCorp `azurerm` provider. The code itself is 12 lines of HCL. The repo exists because of the 5 setup postmortems that stood between `winget install` and a successful `terraform apply`.

---

## 🎯 What this project proves

- **Terraform fundamentals**: HCL syntax, provider pinning, the `init → plan → apply` rhythm, idempotent deployments
- **Real Azure deployment**: not sandbox — resources landed in the same production subscription that hosts my [Module 1 capstone](https://github.com/t-yanick/nimbus-azure-capstone)
- **State discipline**: `.tfstate` understood as sensitive data; `.gitignore` configured before the first commit; lock file committed, state file never
- **Cross-platform setup rigor**: Terraform CLI + Azure CLI + Git Bash + VS Code wrestled into working together on Windows 11

---

## 📁 Repository shape

```
nimbus-module3-terraform/
├── README.md                   ← you are here
├── ERRORS.md                   ← raw error log kept during the lesson
├── .gitignore                  ← excludes .tfstate*, .terraform/, *.tfvars
└── terraform-rg-project/
    ├── providers.tf            ← azurerm provider declaration
    ├── main.tf                 ← azurerm_resource_group.example
    └── .terraform.lock.hcl     ← pinned to azurerm v5.0.0 (committed)
```

**This repo is a frozen artifact for Lesson 1 only.** Lessons 4–11 of Module 3 (AKS, ACR, Key Vault, Storage, Blob, RBAC, remote state, variables, outputs, final apply) build one growing stack and live in a separate repo — link added here once that repo exists.

---

## 🔧 Environment

| Component | Version |
|---|---|
| Terraform | v1.16.5 |
| azurerm provider | v5.0.0 |
| Azure CLI | installed via winget |
| Shell | Git Bash on Windows 11 |
| Target region | South Africa North |

---

## 🚀 How to run it

```bash
# 1. Authenticate to Azure (device-code flow is more reliable than browser callback)
az login --use-device-code

# 2. Enter the Terraform project
cd terraform-rg-project

# 3. The three-command rhythm
terraform init    # downloads the azurerm provider plugin
terraform plan    # shows what WILL change — nothing created yet
terraform apply   # creates the Resource Group in Azure

# 4. ALWAYS clean up when done to avoid cloud costs on future lessons
terraform destroy
```

Expected final line:
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---

## 📄 The Terraform code

**`providers.tf`**
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

**`main.tf`**
```hcl
resource "azurerm_resource_group" "example" {
  name     = "nimbus-rg"
  location = "southafricanorth"
}
```

Two files, 12 lines of HCL, one real Resource Group in Azure. The simplicity is the point — Lesson 1 is the smallest possible but complete Terraform project.

---

## 🔥 Postmortems

Production-style write-ups for the 5 significant errors I hit before `terraform apply` worked. Each one is documented with root cause, resolution, and the general principle it taught me.

### Postmortem #1 — Terraform installed but Git Bash can't see it

**Severity**: 🟢 Low
**Status**: ✅ Resolved
**Time lost**: ~20 min

**What happened**: After `winget install Hashicorp.Terraform` in PowerShell, `terraform version` worked in PowerShell but Git Bash returned `bash: terraform: command not found`. Added what I thought was the right path to `~/.bashrc` — still broken. Added it to the VS Code integrated terminal — still broken.

**Root cause**: Two issues stacked.
1. Git Bash caches `$PATH` at launch — a new install isn't visible until the shell fully restarts.
2. My first guess at the winget install directory was wrong. The real path is `/c/Users/PC/AppData/Local/Microsoft/WinGet/Links`, not the Chocolatey-style path I'd assumed.

**Resolution**:
```bash
echo 'export PATH="$PATH:/c/Users/PC/AppData/Local/Microsoft/WinGet/Links"' >> ~/.bashrc
# close Git Bash entirely, reopen
terraform version
```

**Lessons learned**:
- After editing `~/.bashrc`, close the terminal fully — `source ~/.bashrc` reloads only the current shell, and new processes still inherit the parent's old environment.
- For VS Code integrated terminals, close VS Code itself, not just the terminal tab. The terminal inherits the editor's environment, which is set once at launch.
- Before guessing a path, confirm the real install location with `where <command>` in PowerShell.

---

### Postmortem #2 — Azure CLI silently absent

**Severity**: 🟢 Low
**Status**: ✅ Resolved

**What happened**: Assumed `az` would be available after installing Terraform. It wasn't. `az login` returned `bash: az: command not found`.

**Root cause**: Azure CLI is a completely separate tool from Terraform. Terraform calls Azure's REST API, but authentication is delegated to whatever credentials `az login` has cached. No `az` = no auth = no deploy.

**Resolution**:
```powershell
winget install -e --id Microsoft.AzureCLI
```
Then restart the shell.

**Lessons learned**: Terraform provider documentation always lists its auth prerequisites. Read them BEFORE the first `terraform init`, not after it fails. For `azurerm`, acceptable auth is: Azure CLI, Service Principal, or Managed Identity.

---

### Postmortem #3 — `az login` hung indefinitely on browser callback

**Severity**: 🟡 Medium (silent hang — no error message to search)
**Status**: ✅ Resolved + default behavior changed

**What happened**: `az login` opened a browser, I signed in successfully, the browser displayed *"Vous vous êtes connecté"* (you're signed in) — and then the terminal hung. Ten minutes. No error, no output, just a blinking cursor.

**Root cause**: The browser-based OAuth callback flow depends on a local server that `az` spins up to catch the redirect from Microsoft. On some Windows network configurations (firewalls, antivirus, VPNs, port conflicts) that redirect never lands, and `az` has no timeout — it waits forever.

**Resolution**:
```bash
az login --use-device-code
```
Device-code flow doesn't need a callback — you type a code into a browser URL yourself. Takes 30 seconds and always works.

**Lessons learned**: For any CLI auth flow, prefer device-code when it's offered. Slightly less convenient but zero dependency on local networking. I now use `--use-device-code` as my default for every `az login`.

---

### Postmortem #4 — Microsoft defaulted to passkey, passkey failed

**Severity**: 🟢 Low
**Status**: ✅ Resolved

**What happened**: During `az login`, the Microsoft sign-in page defaulted to passkey authentication. My device had no passkey registered. Got the French error: *"Nous n'avons pas pu vous connecter — Un problème s'est produit lors de la tentative de connexion avec une clé d'accès."*

**Root cause**: Modern Microsoft login tries passwordless methods first (passkey, Authenticator app). If none are configured, it still shows the passkey prompt by default before offering fallback options.

**Resolution**: Click **"Connectez-vous autrement"** (Sign in differently) → choose password.

**Lessons learned**: Microsoft's sign-in UI changes often. The "sign in differently" link is always available, usually in small type below the main button. Don't retry the failing method — look for the alternative.

---

### Postmortem #5 — AADSTS530035: Security Defaults blocked the CLI

**Severity**: 🟠 High (blocked the entire deployment)
**Status**: ✅ Resolved — the longest debugging session of the setup

**What happened**: After solving everything above, `az login` finally succeeded. Then:
```
AADSTS530035: Application 'Microsoft Azure CLI' is blocked by your
organization's conditional access policy.
No subscriptions found for tazoh_yanick@outlook.com.
Device state: Unregistered
```

Tried everything:
- Normal `az login` → blocked
- `az login --tenant <tenant-id>` → blocked
- `az login --tenant <tenant-id> --use-device-code` → still blocked

Classic chicken-and-egg: couldn't deploy because I couldn't authenticate; couldn't fix the auth policy from the CLI because the only way in was through the Portal.

**Root cause**: Microsoft Entra ID **Security Defaults** were enabled on my personal tenant. Security Defaults enforce "require MFA + registered device" for admin tools like Azure CLI. My laptop wasn't registered in Entra, so even correct MFA couldn't unblock the login.

**Resolution**: Portal → Microsoft Entra ID → Properties → **Manage security defaults** → **Disabled**. Then `az login --use-device-code` worked immediately and the subscription appeared.

**Trade-off accepted**: My personal tenant has one user (me). Disabling Security Defaults loses the "always require MFA" guarantee, but gains CLI access from any device. For a learning tenant this trade-off is acceptable. For a production tenant with multiple users or sensitive workloads I would NOT disable Security Defaults — I'd register the device in Entra first (Windows Settings → Accounts → Access work or school → Connect).

**Lessons learned**:
- Entra Security Defaults are ON by default for all tenants created after October 2019. If you've never touched the setting, you have them.
- `AADSTS530035` + `Device state: Unregistered` is the specific fingerprint of this problem. Don't waste time retrying auth — go straight to the policy.
- Always classify a login failure as credential-level or policy-level. The error code (`AADSTS###`) tells you which.

---

## 🧠 Overall Lessons Learned

1. **The deploy is 10% of the work.** Setup, auth, cross-platform shell issues, and tenant policy are the other 90%. Budget accordingly on every new tool.

2. **Device-code auth beats browser-callback auth** for every CLI tool that offers both. More reliable, no local-port surprises, no firewall mysteries.

3. **State files are secrets.** `terraform.tfstate` plain-texts every resource property, sometimes including credentials. Never commit it. Write `.gitignore` BEFORE the first `terraform init`, not after.

4. **Commit the lock file, not the state file.** `.terraform.lock.hcl` pins provider versions — HashiCorp recommends committing it, and it makes `terraform init` reproducible across machines and teammates. `terraform.tfstate` is runtime data, never source.

5. **`terraform destroy` after every lesson.** A Resource Group with no resources inside it is free, but the habit of cleaning up prevents expensive surprises in later lessons that will spin up AKS clusters and Private Endpoints.

---

## 👤 About

Built by **Tazoh Yanick Tazoh** ([@t-yanick](https://github.com/t-yanick)) — DevOps Engineer at Nimbus Compute (UK), pivoting from Computer Science teaching in Yaoundé, Cameroon into cloud and platform engineering.

**Related work**:
- [nimbus-azure-capstone](https://github.com/t-yanick/nimbus-azure-capstone) — Module 1: two-region zero-trust Azure topology (hub-and-spoke, Private Endpoints, Bastion, Managed Identity)
- [nimbus-linux-essentials](https://github.com/t-yanick/nimbus-linux-essentials) — Module 2: 20 Git Bash hands-on challenges with 4 production-style postmortems

**Connect**: [LinkedIn](https://www.linkedin.com/in/tazoh-yanick-tazoh/) · tyankee15@gmail.com

🇨🇲 → 🇨🇦

---

## 📄 License

MIT
