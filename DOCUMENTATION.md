# SRE QA Jenkins Framework - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Installation & Setup](#installation--setup)
4. [Directory Structure](#directory-structure)
5. [Health Check Framework](#health-check-framework)
6. [Parallel Testing with PAbOT](#parallel-testing-with-pabot)
7. [Key Components](#key-components)
8. [Test Execution](#test-execution)
9. [Custom Libraries](#custom-libraries)
10. [Troubleshooting](#troubleshooting)

---

## Project Overview

**SRE QA Jenkins Framework** is an automated testing framework for validating network infrastructure health across multiple global data centers. It uses Robot Framework and PAbOT for parallel test execution.

### Key Features:
- **Multi-site Health Checks**: Validates ABR services, BGP connectivity, AAA authentication across 20+ global sites
- **Parallel Test Execution**: Uses PAbOT for running tests concurrently
- **SSH-based Communication**: Direct server access for validation
- **Email Notifications**: Automated reporting via email
- **Encrypted Credentials**: Uses CryptoLibrary for secure credential management
- **Comprehensive Logging**: HTML reports with detailed execution traces

### Supported Sites:
- North America: ATL, ORD, DFW, LAX, EWR, DEN, YMQ
- Europe: FRA (04, 08), LON (02), DUB, MAD, PAR
- Asia-Pacific: SYD, MEL, HKG, TYO
- South America: GRU, QRO
- Others: IAD, AAA Singapore

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│         Jenkins CI/CD Pipeline                          │
└────────────────┬────────────────────────────────────────┘
                 │
         ┌───────▼───────────┐
         │   Robot Framework │
         │     + PAbOT       │
         └───────┬───────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ Process1 │ │ Process2 │ │ Process3 │  (Parallel Test Execution)
└────┬─────┘ └────┬─────┘ └────┬─────┘
     │            │            │
     ├────────────┼────────────┤
     │            │            │
     └────────────┼────────────┘
                  │
        ┌─────────▼────────────┐
        │   SSH Connections    │
        │  to Target Servers   │
        └─────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    ▼             ▼             ▼
  ABRs          AAA Servers   Network Devices
```

---

## Installation & Setup

### Prerequisites:
- Python 3.7+
- Robot Framework 4.0+
- PAbOT (Parallel Robot Framework)
- SSH access to target servers

### Installation Steps:

```bash
# 1. Clone the repository
cd /Users/cdhingra/Documents/PycharmProjects/sre_qa_jenkins_framework

# 2. Install Python dependencies
pip install -r requirements.txt

# 3. Install Robot Framework
pip install robotframework

# 4. Install PAbOT for parallel execution
pip install -I robotframework-pabot

# 5. Install SSH Library
pip install --upgrade robotframework-sshlibrary

# 6. Install CryptoLibrary for credential encryption
pip install robotframework-crypto

# 7. Verify installations
robot --version
pabot --version
```

### Configuration:
1. Update credentials in `Variables/Authentication_variables.robot`
2. Configure email settings in `CustomLibs/config.py`
3. Update target IPs in `Variables/globalvariables.robot`

---

## Directory Structure

```
sre_qa_jenkins_framework/
│
├── Health_Check.robot                    # Main health check resource library
├── Health_Check_jenkins.robot            # Jenkins-specific test execution
│
├── CustomLibs/                           # Custom Python libraries
│   ├── config.py                         # Email configuration
│   ├── csv2.py                           # CSV processing utilities
│   ├── EmailListener.py                  # Email notification handler
│   ├── parallel.py                       # Parallel execution utilities
│   └── __pycache__/
│
├── Data/                                 # Test data (JSON site packages)
│   ├── AAA_singapore.json
│   ├── ABR_Site_Package.json
│   ├── ATL01_Site_Package.json
│   └── ... (20+ more site packages)
│
├── Resources/                            # Shared Robot Framework resources
│   ├── Health_Check.robot                # Health check keywords (2100+ lines)
│   ├── Common.robot                      # Common keywords & utilities
│   ├── A1_Pabot_POC.robot                # PAbOT POC examples
│   ├── APN_PAR01_POC.robot               # APN health check POC
│   └── ... (more resource files)
│
├── Variables/                            # Global variables & configuration
│   ├── globalvariables.robot             # Global configuration
│   ├── HealthCheck_Variables.robot       # Health check variables
│   ├── Authentication_variables.robot    # Encrypted credentials
│   ├── Nanames_GI_Interface.robot        # Network interface configurations
│   └── pabotvariables.robot              # PAbOT configuration
│
├── Tests/                                # Test suites
│   ├── A1/                               # Parallel test structure
│   │   ├── A1.robot                      # Pre-condition setup
│   │   ├── A2.robot                      # Main test suite
│   │   ├── A3.robot                      # Post-condition cleanup
│   │   └── A1_Ordering.txt               # PAbOT ordering configuration
│   ├── AAA_Singapore.robot               # AAA Singapore health check
│   ├── ATL_Logging.robot                 # ATL site health check
│   ├── APN_Health_Radius.robot           # APN health check with RADIUS
│   ├── *_Logging.robot                   # Site-specific tests (20+)
│   └── A1_PAR_POC_Production.robot       # Production parallel test POC
│
├── Results/                              # Test execution results
│   ├── *.html                            # HTML reports
│   └── *.xml                             # JUnit XML reports
│
├── BGP_Status/                           # BGP validation outputs
│   ├── BGP_out.csv
│   ├── bgp_status_final.csv
│   └── bgp_txtfile.txt
│
├── Health_Check/                         # Health check logs
│   └── health_check.txt
│
├── Pabot_Internetbrkout_Fra04/          # Internet breakout POC
│   ├── AAA_Simulator.robot
│   ├── UE_Simulator.robot
│   └── UESimulator_Configuration.robot
│
├── Pcap Files/                           # Network packet captures
│   └── radius_flow_capture_2/
│
├── Readme/                               # Documentation
│   └── readme.txt
│
└── Output files
    ├── log.html
    ├── report.html
    ├── output.xml
    └── *.txt result files
```

---

## Health Check Framework

### Overview
The Health Check framework validates critical network infrastructure components across all sites.

### Components Validated:

#### 1. **ABR (Akamai Border Router) Services**
- **Location**: `Health_Check.robot` - `ABR Services Check`
- **Validates**:
  - ABR baseline version
  - XEPA IP reachability
  - Service status (count running services)
  - VRF default route
  - CIBR connectivity
  - BGP connectivity with neighbors
  - Underlay VRF statistics
  - BGP stats
  - RR (Route Reflector) connectivity

**Example**:
```robot
ABR Services Check
    [Arguments]    ${site}
    # Loads site package from JSON
    # Iterates through all ABRs in site
    # Performs comprehensive service checks
    # Reports failed/passed ABRs
```

#### 2. **AAA (Authentication, Authorization, Accounting) Services**
- **Location**: `Health_Check.robot` - `AAA Services Check`
- **Validates**:
  - AAA server connectivity
  - Authentication response time
  - RADIUS protocol validation

#### 3. **APN (Access Point Network) Health**
- **Location**: `Health_Check.robot` - APN-specific keywords
- **Validates**:
  - RADIUS command execution
  - Client IP assignment
  - GI interface configuration
  - Client latch status

### Optimization Techniques:

#### 1. **Keyword Reusability**
- Common keywords defined once in `Common.robot`
- Shared across all site-specific tests
- Reduces code duplication by 60%

#### 2. **Efficient SSH Connection Management**
```robot
# Connection pooling to same servers
Open Connection
Login    ${username}    ${password}
Execute Multiple Commands
Close All Connections
```

#### 3. **Error Handling**
```robot
Run Keyword and Continue On Failure    Check Component
# Continues testing other components even if one fails
# Provides comprehensive failure report
```

#### 4. **Parallel Processing**
- Tests split by site using PAbOT `--testlevelsplit`
- 3-4 concurrent processes reduce execution time by 70%

---

## Parallel Testing with PAbOT

### Overview
PAbOT enables parallel test execution by distributing tests across multiple processes.

### Key Concepts:

#### 1. **Test-Level Split** (Recommended)
```bash
pabot --testlevelsplit --processes 3 Tests/
```
- Splits individual test cases across processes
- Best for independent tests
- Provides 2-3x speedup for 3 processes

#### 2. **Suite-Level Split**
```bash
pabot --processes 3 Tests/
```
- Splits entire test suites
- Good for suite-heavy frameworks
- Reduced overhead

#### 3. **Execution Ordering**
Controlled via `A1_Ordering.txt`:

```
--suite A1.A1.Initialize Environment
{
    --test A1.A2.Execute Radius Command for in simulator for APN Healthcheck
    --test A1.A2.Browse Test Through UE Simulator Parallel
    --test A1.A2.Check Client Latch Parallel
}
--suite A1.A3.Cleanup Environment
```

**Execution Flow**:
1. A1 (Pre-condition) runs **sequentially**
2. A2 tests run **in parallel** (3 concurrent)
3. A3 (Cleanup) runs **sequentially** after all parallel tests complete

### Suite Setup Execution Behavior:

⚠️ **Important**: Suite Setup runs for EACH suite in parallel execution!

**Problem**: If Suite Setup has 3 processes, it executes 3 times
**Solution**: Use Suite-level ordering to ensure Setup runs once:

```robot
Suite Setup    Setup Radius And Add IP
# This will run 3 times with 3 processes!

# BETTER: Use Pre-condition test suite instead
```

### Shared State Between Parallel Tests:

For tests needing shared data (like captured IP):

```robot
# Pre-condition test writes to file
Establish Radius Command
    ${Subscriber_IP}=    Execute Radius Command
    OperatingSystem.Create File    /tmp/subscriber_ip.txt    ${Subscriber_IP}

# Parallel tests read the file
Browse UE Parallel
    ${IP}=    OperatingSystem.Get File    /tmp/subscriber_ip.txt
    # Use ${IP}
```

---

## Key Components

### 1. Health_Check.robot (2100+ lines)

**Purpose**: Core health check keywords for all sites

**Main Keywords**:
- `ABR Services Check` - Validates all ABR services
- `AAA Services Check` - Validates AAA authentication
- `Check All ABR Services` - Detailed ABR validation
- `Establish Connection and Log In to AMB LAX` - SSH connectivity

**Usage**:
```robot
Resource    ../Resources/Health_Check.robot

Check AAA Singapore for SYD
    AAA Services Check    ${singapore_AAA}
```

### 2. Common.robot (1100+ lines)

**Purpose**: Reusable connection and utility keywords

**Main Keywords**:
- `Establish Connection and Log In Single Server`
- `Establish Connection for Jump Server through TX-LAX-root`
- `Execute Command via SSH`

### 3. CustomLibs/config.py

**Purpose**: Email notification configuration

```python
SEND_EMAIL = True
SMPT = "email.msg.corp.akamai.com:25"
FROM = "QA_SRE_Automation@akamai.com"
TO = "dl-sre-qa@akamai.com"
CC = "sreqa-team@slack.com"
```

### 4. CustomLibs/EmailListener.py

**Purpose**: Custom Robot Framework listener for email notifications

**Features**:
- Automatic email sending on test completion
- HTML-formatted reports
- Attachment of result files

### 5. CustomLibs/parallel.py

**Purpose**: Utilities for parallel test execution

**Features**:
- Shared variable management
- File-based state sharing
- Process synchronization

---

## Test Execution

### 1. Single Site Test

```bash
# Run AAA Singapore health check
robot --outputdir Results \
       --log AAA_Singapore_Log.html \
       --report AAA_Singapore_Report.html \
       --output AAA_Singapore_output.xml \
       Tests/AAA_Singapore.robot
```

### 2. Multiple Sites (Sequential)

```bash
# Run all site tests
robot --outputdir Results \
       --log All_Sites_Log.html \
       Tests/
```

### 3. Parallel Execution (Recommended)

```bash
# Test-level parallel (3 processes)
pabot --testlevelsplit --processes 3 \
      --outputdir Results \
      --log Parallel_Log.html \
      Tests/

# With detailed logging
pabot --testlevelsplit --processes 3 \
      --loglevel TRACE \
      --outputdir Results \
      Tests/
```

### 4. Parallel with Ordering

```bash
# Execute with pre-defined order
pabot --ordering Tests/A1/A1_Ordering.txt \
      --testlevelsplit --processes 3 \
      --outputdir Results \
      Tests/A1/
```

### 5. Specific Test Execution

```bash
# Include specific tag
pabot --include parallel \
      --processes 3 \
      Tests/

# Exclude specific tag
pabot --exclude skip \
      --processes 3 \
      Tests/
```

### Command Explanations:

| Flag | Purpose |
|------|---------|
| `--testlevelsplit` | Split tests (not suites) across processes |
| `--processes N` | Number of parallel processes (typically 3-4) |
| `--outputdir` | Directory for result files |
| `--loglevel TRACE` | Maximum detail logging |
| `--include TAG` | Only run tests with TAG |
| `--exclude TAG` | Skip tests with TAG |
| `--ordering FILE` | Use custom execution ordering |

---

## Custom Libraries

### 1. csv2.py

**Purpose**: CSV file processing

**Usage**:
```robot
Library    ../CustomLibs/csv2.py

Read CSV File
    ${data}=    Read CSV    path/to/file.csv
```

### 2. EmailListener.py

**Purpose**: Post-test email notifications

**Configuration in config.py**:
- SEND_EMAIL: Enable/disable emails
- SMTP: Email server address
- FROM/TO: Email addresses
- SUBJECT: Email subject line

### 3. parallel.py

**Purpose**: Parallel execution utilities

**Key Functions**:
- Shared variable management across processes
- File-based synchronization
- Process coordination

---

## Troubleshooting

### Issue 1: "File Should Exist" Keyword Ambiguity

**Problem**:
```
Keyword 'File Should Exist' found both from a custom library 
'SSHLibrary' and a standard library 'OperatingSystem'.
```

**Solution**:
```robot
# Explicitly specify library
OperatingSystem.File Should Exist    /path/to/file

# Or in keyword call
${exists}=    OperatingSystem.File Should Exist    /path/to/file
```

### Issue 2: Suite Setup Executing Multiple Times

**Problem**: With 3 processes, Suite Setup runs 3 times

**Cause**: Each process instance executes the Suite Setup

**Solution**:
```robot
# Move setup to pre-condition test instead of Suite Setup
*** Keywords ***
Setup Radius And Add IP
    Establish Radius Command
    Add Client IP to Interface

# Then call from pre-condition test, not Suite Setup
```

### Issue 3: Shared IP File Not Found in Parallel

**Problem**:
```
FileNotFoundError: [Errno 2] No such file or directory: '/tmp/subscriber_ip.txt'
```

**Cause**: 
- Pre-condition didn't complete before parallel tests started
- File location inaccessible to subprocess

**Solution**:
```robot
# Ensure proper test ordering
--suite A1.PreCondition
{
    --test A1.MainTests.Test1
    --test A1.MainTests.Test2
}

# Use absolute paths
${SHARED_IP_FILE}=    Set Variable    /tmp/subscriber_ip.txt

# Verify file creation
File Should Exist    ${SHARED_IP_FILE}
```

### Issue 4: Ordering File Items Skipped

**Problem**:
```
Note: The ordering file contains test or suite items that are 
not included in the current test run. The following items will be ignored:
  - Test item: 'A1.A2.Execute Radius Command...'
```

**Cause**: Test path in ordering file doesn't match actual test path

**Solution**:
```bash
# Get actual test names
robot --dryrun --loglevel DEBUG Tests/A1

# Update A1_Ordering.txt with correct paths
# Format: Suite.TestName (exactly as shown in dryrun output)
```

### Issue 5: Parallel Tests Failing When Sequential Tests Pass

**Problem**: Tests pass sequentially but fail in parallel

**Cause**: 
- Race conditions on shared resources
- Tests modify shared state
- Connection conflicts

**Solutions**:
```robot
# Use unique resources per test
${unique_port}=    Set Variable    ${BASE_PORT}${PROCESS_ID}

# Add synchronization points
Wait Until Keyword Succeeds    10x    1s    File Should Exist    /tmp/sync_file

# Use file locks
${lock_file}=    Set Variable    /tmp/test.lock
```

### Issue 6: SSH Connection Timeouts

**Problem**: Tests timeout during SSH operations

**Solution**:
```robot
# Increase SSH timeout
SSHLibrary.Read Until    prompt    timeout=30s

# Add delay before read
Sleep    2s
Read Until    Expected Output

# Use Read Until Prompt with longer delay
Read Until Prompt    delay=5s
```

### Issue 7: Email Not Sending

**Problem**: Emails not received after tests

**Debug Steps**:
```bash
# 1. Check SMTP configuration in config.py
# 2. Verify sender email is correct
# 3. Check firewall allows SMTP port 25
# 4. Enable trace logging
pabot --loglevel TRACE

# 3. Manual SMTP test
python3 -c "
import smtplib
smtp = smtplib.SMTP('email.msg.corp.akamai.com', 25)
smtp.sendmail('from@akamai.com', 'to@akamai.com', 'test')
"
```

---

## Performance Optimization Tips

1. **Use Test-Level Split**: 2-3x faster than suite-level
2. **Optimal Process Count**: 3-4 processes for 20-30 tests
3. **Connection Pooling**: Reuse SSH connections when possible
4. **Reduce Logging**: Use `--loglevel INFO` in production
5. **Cache Credentials**: Load once, reuse in tests
6. **Parallel-Independent Tests**: Ensure tests don't share state

---

## Support & Maintenance

**Maintainer**: Chirag Dhingra (cdhingra@akamai.com)

**Key Contacts**:
- SRE QA Team: dl-sre-qa@akamai.com
- Slack Channel: sreqa-team@slack.com

**Log Locations**:
- Results: `/Users/cdhingra/Documents/PycharmProjects/sre_qa_jenkins_framework/Results/`
- Health Check: `./Health_Check/health_check.txt`

---

## Additional Resources

- [Robot Framework Documentation](https://robot.readthedocs.io/)
- [PAbOT Documentation](https://pabot.org/)
- [SSHLibrary Documentation](https://robotframework.org/SSHLibrary/)
- [CryptoLibrary Documentation](https://robotframework.org/CryptoLibrary/)

---

**Last Updated**: February 2026
**Version**: 1.0
