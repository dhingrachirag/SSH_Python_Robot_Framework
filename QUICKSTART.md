# SRE QA Jenkins Framework - Quick Start Guide

## 📋 What This Project Does

This is an **automated health check framework** that validates network infrastructure across global data centers. It:

✅ Checks ABR (Border Router) services at 20+ sites
✅ Validates AAA (Authentication) servers
✅ Tests APN (Access Point Network) connectivity
✅ Runs tests in parallel for 3x speedup
✅ Sends automated email reports

---

## 🚀 Quick Installation

```bash
# 1. Install dependencies
pip install robotframework
pip install robotframework-pabot
pip install robotframework-sshlibrary
pip install robotframework-crypto

# 2. Configure credentials
# Edit Variables/Authentication_variables.robot

# 3. Run first test
robot Tests/AAA_Singapore.robot
```

---

## 📁 Project Structure

```
├── Health_Check.robot              ← Core health check keywords
├── Tests/                          ← Test cases
│   ├── A1/                        ← Parallel test examples
│   ├── AAA_Singapore.robot        ← AAA health check
│   ├── ATL_Logging.robot          ← Site-specific tests
│   └── ... (more sites)
├── Resources/                     ← Shared keywords
├── Variables/                     ← Configuration
├── CustomLibs/                    ← Python utilities
└── Results/                       ← Test output
```

---

## 🏃 How to Run Tests

### Single Site Test
```bash
robot Tests/AAA_Singapore.robot
```

### Multiple Sites (Sequential)
```bash
robot Tests/
```

### Multiple Sites (Parallel - 3x Faster!)
```bash
pabot --testlevelsplit --processes 3 Tests/
```

### With Detailed Logging
```bash
pabot --testlevelsplit --processes 3 --loglevel TRACE --outputdir Results Tests/
```

### Jenkins Command
```bash
pabot --testlevelsplit --processes 6 --loglevel TRACE --outputdir Results_$BUILD_ID \
      --log Health_Log.html --report Health_Report.html --output Health_output.xml \
      --include parallel Tests/
```

---

## 🔧 Key Configuration Files

### 1. Variables/Authentication_variables.robot
```robot
${chirag_nms_username}    encrypted:your_encrypted_username
${chirag_nms_pass}        encrypted:your_encrypted_password
${ABR_IP}                 1.2.3.4
```

### 2. Variables/globalvariables.robot
```robot
${Host}                   nms.example.com
${denv_host}              denver.example.com
${Common_Path}            Data
```

### 3. CustomLibs/config.py
```python
SEND_EMAIL = True
FROM = "QA_SRE_Automation@akamai.com"
TO = "dl-sre-qa@akamai.com"
SMPT = "email.msg.corp.akamai.com:25"
```

---

## 💡 Understanding Parallel Execution

### Sequential (Slow)
```
Time: 60 minutes
Tests: Run one after another
└─ ATL (15 min) → LAX (15 min) → FRA (15 min) → ORD (15 min)
```

### Parallel with 3 Processes (Fast!)
```
Time: 20 minutes (3x speedup)
Tests: Run simultaneously
├─ Process 1: ATL → FRA
├─ Process 2: LAX → ORD  
└─ Process 3: DFW → EWR
```

### Parallel Pattern
```robot
A1.robot (Pre-condition)  ─┐
                          ├─ Runs sequentially
A2.robot (Main Tests)     ├─ Runs in parallel (3 processes)
                          ├─ Each test is independent
A3.robot (Post-condition) ─┘ Runs sequentially after all
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "File Should Exist" Ambiguity
```robot
# DON'T: ❌ Ambiguous which library
File Should Exist    /tmp/test.txt

# DO: ✅ Explicit library
OperatingSystem.File Should Exist    /tmp/test.txt
```

### Issue 2: Suite Setup Runs 3 Times
```robot
# DON'T: ❌ Runs 3 times in 3-process parallel execution
Suite Setup    Setup Radius And Add IP

# DO: ✅ Use pre-condition test instead (runs once)
*** Test Cases ***
Initialize Environment
    [Documentation]    Setup (runs before parallel tests)
    Setup Radius And Add IP
```

### Issue 3: FileNotFoundError in Parallel
```robot
# Solution: Ensure proper test ordering
--suite A1.PreCondition
{
    --test A1.MainTest1
    --test A1.MainTest2
}
--suite A1.PostCondition
```

### Issue 4: SSH Timeout
```robot
# Increase timeout
Read Until    prompt    timeout=30s

# Add delay before read
Sleep    2s
Read Until    expected_output
```

---

## 📊 Performance Tips

1. **Use Test-Level Split** (Better than suite-level)
   ```bash
   pabot --testlevelsplit --processes 3 Tests/
   ```

2. **Optimal Process Count**: 3-4 (more ≠ faster)
   - 3 processes = 3x speedup
   - 4 processes = 3.3x speedup
   - Beyond 4 = diminishing returns

3. **Reduce Logging in Production**
   ```bash
   pabot --loglevel INFO --processes 3 Tests/
   ```

4. **Reuse Connections** (Don't open/close repeatedly)
   ```robot
   Open Connection    ${Host}
   Login    ${username}    ${password}
   Execute command 1
   Execute command 2
   Execute command 3
   Close All Connections
   ```

---

## 📈 What Gets Checked

### ABR Services
- ✅ Baseline version
- ✅ XEPA IP reachability
- ✅ Running services count
- ✅ VRF default route
- ✅ BGP connectivity
- ✅ RR connectivity

### AAA Services
- ✅ Server connectivity
- ✅ RADIUS protocol
- ✅ Authentication response

### APN Health
- ✅ RADIUS command execution
- ✅ Client IP assignment
- ✅ GI interface status
- ✅ Client latch

---

## 📧 Email Reports

Automatically configured in `CustomLibs/config.py`:

- **From**: QA_SRE_Automation@akamai.com
- **To**: dl-sre-qa@akamai.com
- **CC**: sreqa-team@slack.com
- **Subject**: Health Check Automation Execution Status

Reports include:
- Pass/fail summary
- Failed ABR list
- Execution time
- HTML log attachment

---

## 🎯 Next Steps

1. **Update credentials** in `Variables/Authentication_variables.robot`
2. **Configure sites** in `Variables/globalvariables.robot`
3. **Run a test**: `robot Tests/AAA_Singapore.robot`
4. **Check results**: Open `report.html` in browser
5. **Run parallel**: `pabot --testlevelsplit --processes 3 Tests/`

---

## 📞 Support

**Maintainer**: Chirag Dhingra (cdhingra@akamai.com)

**Documentation**:
- Full docs: `DOCUMENTATION.md`
- Optimization guide: See `Readme/readme.txt`
- Examples: `Resources/A1_Pabot_POC.robot`

---

**Last Updated**: February 2026
**Version**: 1.0
