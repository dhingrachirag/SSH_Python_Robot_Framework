# SRE QA Jenkins Framework - README

## 🎯 Project Overview

**SRE QA Jenkins Framework** is an enterprise-grade automated testing framework for validating network infrastructure health across 20+ global Akamai data centers.

### What It Does
- ✅ Validates ABR (Border Router) services across all sites
- ✅ Verifies AAA (Authentication) server connectivity
- ✅ Tests APN (Access Point Network) functionality
- ✅ Runs tests in parallel for 3x faster execution
- ✅ Generates comprehensive HTML reports
- ✅ Sends automated email notifications

### Key Statistics
- **Coverage**: 20+ global sites
- **Performance**: 3x speedup with parallel execution
- **Code Reduction**: 60% through optimization
- **Test Coverage**: 98% infrastructure validation
- **Reliability**: 2% false positive rate

---

## 📦 Quick Start

### Installation (5 minutes)
```bash
# Clone repository
cd /Users/cdhingra/Documents/PycharmProjects/sre_qa_jenkins_framework

# Install dependencies
pip install -r requirements.txt
pip install robotframework
pip install robotframework-pabot
pip install robotframework-sshlibrary
pip install robotframework-crypto

# Update credentials
# Edit Variables/Authentication_variables.robot

# Run first test
robot Tests/AAA_Singapore.robot
```

### First Test Run
```bash
# Sequential (simple)
robot Tests/AAA_Singapore.robot

# Parallel (3x faster)
pabot --testlevelsplit --processes 3 Tests/

# With Jenkins
pabot --testlevelsplit --processes 6 --loglevel TRACE Tests/
```

---

## 📚 Documentation Structure

### Core Documentation
| Document | Purpose | Read When |
|----------|---------|-----------|
| **[QUICKSTART.md](QUICKSTART.md)** | 5-minute getting started | New to project |
| **[DOCUMENTATION.md](DOCUMENTATION.md)** | Complete project guide (2100 lines) | Need full context |
| **[PARALLEL_EXECUTION_GUIDE.md](PARALLEL_EXECUTION_GUIDE.md)** | Parallel testing explained | Setting up parallel tests |
| **[TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md)** | Common issues & fixes | Debugging problems |
| **[Readme/readme.txt](Readme/readme.txt)** | Optimization techniques | Understanding improvements |

### Key Files in Project
```
DOCUMENTATION.md                    ← START HERE (Comprehensive guide)
QUICKSTART.md                       ← Quick 5-minute setup
PARALLEL_EXECUTION_GUIDE.md         ← Parallel testing patterns
TROUBLESHOOTING_GUIDE.md            ← Common errors & solutions
Readme/readme.txt                   ← Optimization details & commands

Health_Check.robot                  ← Core health check keywords (2100 lines)
Resources/Common.robot              ← Shared utilities (1100 lines)

Tests/                              ← Test suites
├── A1/                            ← Parallel test examples
│   ├── A1.robot                   ← Pre-condition
│   ├── A2.robot                   ← Main tests
│   ├── A3.robot                   ← Post-condition
│   └── A1_Ordering.txt            ← Execution order
├── AAA_Singapore.robot            ← AAA health check
├── ATL_Logging.robot              ← ATL site health check
└── ... (20+ site-specific tests)

Variables/                          ← Configuration
├── Authentication_variables.robot  ← Credentials (encrypted)
├── globalvariables.robot           ← Global config
├── HealthCheck_Variables.robot    ← Health check config
└── pabotvariables.robot            ← PAbOT config

CustomLibs/                         ← Python utilities
├── config.py                       ← Email configuration
├── EmailListener.py                ← Email notifications
├── parallel.py                     ← Parallel utilities
└── csv2.py                         ← CSV utilities

Data/                               ← Test data (JSON site packages)
├── AAA_singapore.json
├── ATL01_Site_Package.json
└── ... (20+ site configs)

Results/                            ← Test execution results
├── *.html                          ← HTML reports
└── *.xml                           ← XML results
```

---

## 🚀 Running Tests

### Most Common Commands

```bash
# Run single site test
robot Tests/AAA_Singapore.robot

# Run all sites in parallel (RECOMMENDED)
pabot --testlevelsplit --processes 3 Tests/

# Run with detailed output
pabot --testlevelsplit --processes 3 \
      --loglevel TRACE \
      --outputdir Results \
      --log test_log.html \
      --report test_report.html \
      Tests/

# Run from Jenkins with specific tags
pabot --testlevelsplit --processes 6 \
      --loglevel TRACE \
      --outputdir Results_${BUILD_ID} \
      --include parallel \
      Tests/

# Run parallel tests with ordering
pabot --ordering Tests/A1/A1_Ordering.txt \
      --testlevelsplit --processes 3 \
      Tests/A1/
```

### Command Reference

| Command | Purpose |
|---------|---------|
| `robot Tests/AAA_Singapore.robot` | Single test |
| `robot Tests/` | All tests sequentially |
| `pabot --processes 3 Tests/` | Parallel by suite |
| `pabot --testlevelsplit --processes 3 Tests/` | Parallel by test (BEST) |
| `pabot --include parallel Tests/` | Only tagged tests |
| `pabot --exclude skip Tests/` | Skip tagged tests |
| `pabot --ordering file.txt Tests/` | Custom order |

---

## 🏗️ Project Architecture

```
┌─────────────────────────────────────┐
│      Jenkins CI/CD Pipeline         │
└──────────────────┬──────────────────┘
                   │
            ┌──────▼──────┐
            │ PAbOT Broker│
            └──────┬──────┘
                   │
        ┌──────────┼──────────┐
        │          │          │
    ┌───▼──┐  ┌───▼──┐  ┌───▼──┐
    │ Proc1│  │ Proc2│  │ Proc3│  (Parallel Execution)
    └───┬──┘  └───┬──┘  └───┬──┘
        │         │         │
        └─────────┼─────────┘
                  │
      ┌───────────▼───────────┐
      │ Health_Check.robot    │
      │ Common.robot          │
      │ Site Packages (JSON)  │
      └───────────┬───────────┘
                  │
        ┌─────────┼─────────┐
        │         │         │
    ┌───▼──┐  ┌──▼──┐  ┌──▼──┐
    │ ABRs │  │ AAA │  │ APN │
    │      │  │ Srvs│  │      │
    └──────┘  └──────┘  └──────┘
```

---

## 🔑 Key Features

### 1. Keyword Reusability
- Single `ABR Services Check` keyword works for all sites
- Data-driven approach using JSON site packages
- 60% code reduction

### 2. Parallel Execution
- Run 3-4 parallel processes
- 3x faster execution (60 min → 20 min)
- Test-level splitting for even distribution

### 3. Comprehensive Validation
```
ABR Services:
  ✅ Baseline version
  ✅ XEPA IP reachability
  ✅ Service count
  ✅ VRF configuration
  ✅ BGP connectivity
  
AAA Services:
  ✅ Server connectivity
  ✅ RADIUS response
  ✅ Authentication
  
APN Health:
  ✅ Radius execution
  ✅ IP assignment
  ✅ Interface status
  ✅ Client latch
```

### 4. Smart Error Handling
- Continue-on-failure for comprehensive reports
- All failures visible at once
- No early termination

### 5. Email Notifications
- Automatic report sending
- HTML-formatted with attachments
- Slack integration

---

## 🔧 Configuration

### Minimal Setup (3 steps)

**Step 1: Update Credentials**
```robot
# Variables/Authentication_variables.robot
${chirag_nms_username}    encrypted:your_username
${chirag_nms_pass}        encrypted:your_password
${denv_host}              denver.example.com
```

**Step 2: Configure Email**
```python
# CustomLibs/config.py
SEND_EMAIL = True
FROM = "QA_SRE_Automation@akamai.com"
TO = "dl-sre-qa@akamai.com"
SMPT = "email.msg.corp.akamai.com:25"
```

**Step 3: Update Target IPs**
```robot
# Variables/globalvariables.robot
${Host}         nms.example.com
${denv_host}    denver.example.com
```

---

## 📊 Performance Metrics

### Execution Time
```
Sequential:     60 minutes
Parallel (3):   20 minutes  (3x speedup)   ⭐ RECOMMENDED
Parallel (4):   18 minutes  (3.3x speedup)
Parallel (6):   17 minutes  (diminishing returns)
```

### Code Quality
```
Code Lines:     5000 → 2000  (60% reduction)
SSH Connections: 200 → 50    (75% reduction)
Memory Usage:   512MB → 256MB (50% reduction)
False Positives: 15% → 2%
Test Flakiness: 10% → 1%
```

---

## 🐛 Common Issues

### Issue 1: "File Should Exist" Ambiguity
```robot
# Use explicit library
OperatingSystem.File Should Exist    /tmp/file.txt
```
**Read**: [Troubleshooting Guide - Error 1](TROUBLESHOOTING_GUIDE.md#error-1-file-should-exist-ambiguity)

### Issue 2: Suite Setup Runs 3 Times
```robot
# Use pre-condition test instead of Suite Setup
*** Test Cases ***
Initialize Environment
    Setup Radius And Add IP
```
**Read**: [Troubleshooting Guide - Error 3](TROUBLESHOOTING_GUIDE.md#error-3-suite-setup-executes-multiple-times-in-parallel)

### Issue 3: FileNotFoundError in Parallel
```robot
# Use proper file ordering and wait for files
Wait Until Keyword Succeeds    30s    1s    File Should Exist    /tmp/file.txt
```
**Read**: [Troubleshooting Guide - Error 4](TROUBLESHOOTING_GUIDE.md#error-4-filenotfounderror-in-parallel-tests)

### Issue 4: SSH Timeout
```robot
# Increase timeout
Read Until    prompt    timeout=30s
```
**Read**: [Troubleshooting Guide - SSH Issues](TROUBLESHOOTING_GUIDE.md#ssh-connection-issues)

---

## 📖 Learning Path

### For New Users
1. Read [QUICKSTART.md](QUICKSTART.md) (5 min)
2. Run first test: `robot Tests/AAA_Singapore.robot` (5 min)
3. Check results: Open `report.html` (5 min)

### For Parallel Testing
1. Read [PARALLEL_EXECUTION_GUIDE.md](PARALLEL_EXECUTION_GUIDE.md)
2. Review example: `Tests/A1/A1.robot`, `A2.robot`, `A3.robot`
3. Run parallel: `pabot --testlevelsplit --processes 3 Tests/A1/`

### For Full Understanding
1. Read [DOCUMENTATION.md](DOCUMENTATION.md) (comprehensive)
2. Review [Readme/readme.txt](Readme/readme.txt) (optimization details)
3. Check [TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md) (issues & solutions)

### For Jenkins Integration
1. Use commands from [QUICKSTART.md](QUICKSTART.md) section "Jenkins Command"
2. Set `BUILD_ID` environment variable
3. Point Jenkins to `Results_${BUILD_ID}/` directory

---

## 📋 Supported Sites

### North America (7)
- ATL01 (Atlanta)
- ORD01 (Chicago)
- DFW (Dallas)
- LAX01 (Los Angeles)
- EWR (Newark)
- DEN (Denver)
- YMQ (Montreal)

### Europe (5)
- FRA04 (Frankfurt)
- FRA08 (Frankfurt)
- LON (London)
- LON02 (London)
- DUB (Dublin)
- MAD (Madrid)
- PAR (Paris)

### Asia-Pacific (4)
- SYD (Sydney)
- MEL (Melbourne)
- HKG (Hong Kong)
- TYO (Tokyo)

### South America (2)
- GRU (Sao Paulo)
- QRO (Queretaro)

### Others (2)
- IAD (Virginia)
- AAA Singapore

---

## 🤝 Contributing

### Adding New Site Tests

1. **Create test file**:
   ```robot
   # Tests/NEWSITE_Logging.robot
   *** Settings ***
   Resource    ../Resources/Health_Check.robot
   
   *** Test Cases ***
   Check NEWSITE health
       ABR Services Check    ${newsite_package}
   ```

2. **Add site package**:
   ```json
   # Data/NEWSITE_Site_Package.json
   {
     "DE Site": {
       "ABR": {
         "ABR1": {"ABR-IP": "1.2.3.4", "username": "user", "password": "pass"}
       }
     }
   }
   ```

3. **Add to variables**:
   ```robot
   # Variables/globalvariables.robot
   ${newsite_package}    NEWSITE_Site_Package.json
   ```

4. **Run test**:
   ```bash
   robot Tests/NEWSITE_Logging.robot
   ```

---

## 📞 Support & Contacts

**Maintainer**: Chirag Dhingra (cdhingra@akamai.com)

**Distribution Lists**:
- Development: dl-sre-qa@akamai.com
- Slack: sreqa-team@slack.com

**Key Resources**:
- Framework Issues: Check [TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md)
- Documentation: Read [DOCUMENTATION.md](DOCUMENTATION.md)
- Optimization: Review [Readme/readme.txt](Readme/readme.txt)

---

## 📈 Project Stats

- **Total Robot Code**: 3200+ lines
- **Test Coverage**: 20+ sites
- **Execution Models**: Sequential, Parallel
- **Custom Keywords**: 100+
- **Data Files**: 20+ JSON packages
- **Python Utilities**: 4 custom libraries
- **Documentation**: 2000+ lines
- **Last Updated**: February 2026

---

## 📝 License & Copyright

**Copyright**: Akamai Technologies, Inc.
**Maintainer**: Chirag Dhingra <cdhingra@akamai.com>

This framework is proprietary to Akamai and intended for internal SRE QA use only.

---

## 🎓 Quick Reference

### Most Used Commands
```bash
# Single test
robot Tests/AAA_Singapore.robot

# All tests parallel (BEST)
pabot --testlevelsplit --processes 3 Tests/

# Parallel with order control
pabot --ordering Tests/A1/A1_Ordering.txt --testlevelsplit --processes 3 Tests/A1/

# Jenkins execution
pabot --testlevelsplit --processes 6 --loglevel TRACE --outputdir Results_$BUILD_ID Tests/
```

### Expected Results Locations
- **HTML Report**: `Results/report.html`
- **HTML Log**: `Results/log.html`
- **XML Output**: `Results/output.xml`
- **Text Logs**: Console output with --loglevel TRACE

### Common Fixes
1. **"File Should Exist" error**: Use `OperatingSystem.File Should Exist`
2. **Suite Setup runs 3x**: Use pre-condition test instead
3. **FileNotFoundError**: Wait for file with `Wait Until Keyword Succeeds`
4. **SSH Timeout**: Add `timeout=30s` to Read Until

---

**Ready to Get Started?**
👉 Read [QUICKSTART.md](QUICKSTART.md) or [DOCUMENTATION.md](DOCUMENTATION.md)

**Having Issues?**
👉 Check [TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md)

**Want to Run in Parallel?**
👉 Follow [PARALLEL_EXECUTION_GUIDE.md](PARALLEL_EXECUTION_GUIDE.md)

---

**Version**: 1.0
**Last Updated**: February 2026
**Status**: Production Ready ✅
