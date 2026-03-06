# Parallel Test Execution Guide - Complete Reference

## Table of Contents
1. [Overview](#overview)
2. [Test Structure](#test-structure)
3. [PAbOT Commands](#pabot-commands)
4. [Ordering Configuration](#ordering-configuration)
5. [Shared State Management](#shared-state-management)
6. [Real-World Examples](#real-world-examples)
7. [Troubleshooting](#troubleshooting)

---

## Overview

### What is Parallel Execution?
Instead of running tests sequentially (one after another), run multiple tests simultaneously on different processes.

### Performance Comparison
```
Sequential Execution:
60 minutes ─────────────────────────────────────────
[ATL][LAX][FRA][ORD][DFW][EWR][IAD][DEN][DUB][FRA08]
10   10   10   10   10   10   10   10   10   10

Parallel Execution (3 processes):
20 minutes ───────────────
[ATL][LAX][FRA]
[ORD][DFW][EWR]
[IAD][DEN][DUB]
[FRA08]

Speed Improvement: 3x (60 min → 20 min)
```

### When to Use Parallel
✅ Independent tests (no shared state)
✅ Long-running suites (60+ minutes)
✅ Many test cases (20+)
✅ CI/CD pipelines needing fast feedback

### When NOT to Use Parallel
❌ Tests share mutable state
❌ Tests need to run in specific order
❌ Database requires sequential access
❌ Very few tests (< 5)

---

## Test Structure

### Basic Pattern: Pre-Condition → Tests → Post-Condition

```
A1.robot (Pre-Condition)
├── Initialize Environment
│   ├── Establish Radius Command
│   ├── Add Client IP to Interface
│   └── Create sync file
│
A2.robot (Main Tests) ← Runs in Parallel
├── Execute Radius Command        (Process 1)
├── Browse Test Through UE        (Process 2)
└── Check Client Latch            (Process 3)
│
A3.robot (Post-Condition)
└── Cleanup Environment
    ├── Delete Client IP
    └── Remove sync files
```

### File 1: A1.robot (Pre-Condition)

```robot
*** Settings ***
Resource    ../Resources/Common.robot
Library     OperatingSystem

*** Test Cases ***
Initialize Environment
    [Documentation]    Setup shared resources (runs once, sequentially)
    Log    Setting up shared resources
    
    # Establish RADIUS connection and get IP
    ${Subscriber_IP}=    Establish Radius Command in AAA Simulator
    Log    Got IP: ${Subscriber_IP}
    
    # Add IP to interface
    Add Client IP to GI Interface    ${Subscriber_IP}
    Log    IP added to interface
    
    # Create flag file for parallel tests
    Create File    /tmp/subscriber_ip.txt    ${Subscriber_IP}
    Create File    /tmp/setup_complete.txt    done
    
    Log    Shared resources ready for parallel tests
```

### File 2: A2.robot (Main Tests - Parallel)

```robot
*** Settings ***
Resource    ../Resources/Common.robot
Library     OperatingSystem

*** Test Cases ***
Execute Radius Command for in simulator for APN Healthcheck
    [Tags]    parallel
    [Documentation]    Parallel test 1
    
    # Wait for setup to complete (file-based synchronization)
    Wait Until Created    /tmp/setup_complete.txt    timeout=30s
    
    Log    Test 1 starting (IP already configured by pre-condition)
    ${Subscriber_IP}=    Get File    /tmp/subscriber_ip.txt
    Log    Using IP: ${Subscriber_IP}
    
    # Perform test operations
    Execute Custom RADIUS Command    ${Subscriber_IP}

Browse Test Through UE Simulator Parallel
    [Tags]    parallel
    [Documentation]    Parallel test 2
    
    # Wait for setup
    Wait Until Created    /tmp/setup_complete.txt    timeout=30s
    
    Log    Test 2 starting
    ${Subscriber_IP}=    Get File    /tmp/subscriber_ip.txt
    Log    Using IP: ${Subscriber_IP}
    
    # Browse through UE simulator
    Browse UE Simulator    ${Subscriber_IP}

Check Client Latch Parallel
    [Tags]    parallel
    [Documentation]    Parallel test 3
    
    # Wait for setup
    Wait Until Created    /tmp/setup_complete.txt    timeout=30s
    
    Log    Test 3 starting
    ${Subscriber_IP}=    Get File    /tmp/subscriber_ip.txt
    Log    Using IP: ${Subscriber_IP}
    
    # Check latch status
    Check Client Latch Status    ${Subscriber_IP}

*** Keywords ***
Wait Until Created
    [Arguments]    ${file_path}    ${timeout}=30s
    Wait Until Keyword Succeeds    ${timeout}    1s    
    ...    File Should Exist    ${file_path}
```

### File 3: A3.robot (Post-Condition)

```robot
*** Settings ***
Resource    ../Resources/Common.robot
Library     OperatingSystem

*** Test Cases ***
Cleanup Environment
    [Documentation]    Cleanup (runs once, sequentially after all parallel tests)
    
    # Get IP from file
    ${Subscriber_IP}=    Get File    /tmp/subscriber_ip.txt
    ${Subscriber_IP}=    Strip String    ${Subscriber_IP}
    Log    Cleaning up IP: ${Subscriber_IP}
    
    # Delete IP from interface
    Delete Client IP from GI Interface    ${Subscriber_IP}
    Log    IP deleted from interface
    
    # Clean up sync files
    Remove File    /tmp/subscriber_ip.txt
    Remove File    /tmp/setup_complete.txt
    
    Log    Cleanup complete
```

---

## PAbOT Commands

### 1. Basic Parallel Execution

```bash
# Run all tests in parallel (3 processes)
pabot --processes 3 Tests/

# Run with specific tag (all tests tagged "parallel")
pabot --include parallel --processes 3 Tests/

# Exclude tests with "skip" tag
pabot --exclude skip --processes 3 Tests/
```

### 2. Test-Level Split (Recommended)

```bash
# Split individual test cases across processes
pabot --testlevelsplit --processes 3 Tests/

# Why? Even distribution of tests
# Better performance than suite-level split
```

### 3. With Logging & Output

```bash
# Comprehensive logging
pabot --testlevelsplit --processes 3 \
      --loglevel TRACE \
      --outputdir Results \
      --log Health_Log.html \
      --report Health_Report.html \
      --output Health_output.xml \
      Tests/
```

### 4. With Ordering File

```bash
# Control execution order
pabot --ordering Tests/A1/A1_Ordering.txt \
      --testlevelsplit --processes 3 \
      Tests/A1/
```

### Command Options Reference

| Option | Purpose | Example |
|--------|---------|---------|
| `--processes N` | Number of parallel processes | `--processes 3` |
| `--testlevelsplit` | Split tests (not suites) | Recommended |
| `--outputdir DIR` | Result output directory | `--outputdir Results` |
| `--loglevel LEVEL` | Logging verbosity | `--loglevel TRACE` or `INFO` |
| `--log FILE` | HTML log file | `--log test_log.html` |
| `--report FILE` | HTML report file | `--report test_report.html` |
| `--output FILE` | XML output file | `--output test_output.xml` |
| `--include TAG` | Run only tests with TAG | `--include parallel` |
| `--exclude TAG` | Skip tests with TAG | `--exclude skip` |
| `--ordering FILE` | Custom execution order | `--ordering order.txt` |

---

## Ordering Configuration

### What is A1_Ordering.txt?

Controls the sequence of test execution when running in parallel.

### Basic Format

```
--suite SuiteName
--test TestName
```

### Example: Pre-Condition → Parallel → Post-Condition

**A1_Ordering.txt**:
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
1. `A1.A1.Initialize Environment` - Runs once, sequentially
2. `A1.A2.*` tests - Run in parallel (all 3 simultaneously)
3. `A1.A3.Cleanup Environment` - Runs once after all parallel complete

### Multi-Group Ordering

```
--suite A1.Setup Suite
{
    --test A1.Test.Test1
    --test A1.Test.Test2
    --test A1.Test.Test3
}
{
    --test A1.Test.Test4
    --test A1.Test.Test5
    --test A1.Test.Test6
}
--suite A1.Cleanup Suite
```

**Execution**:
1. Setup runs once
2. First 3 tests run in parallel
3. Second 3 tests run in parallel
4. Cleanup runs once

---

## Shared State Management

### Problem: How Do Parallel Tests Share Data?

Each process has isolated memory → can't use test variables directly

### Solution 1: File-Based Communication

```robot
# Pre-condition writes
Create File    /tmp/subscriber_ip.txt    ${IP}

# Parallel tests read
${IP}=    Get File    /tmp/subscriber_ip.txt

# Post-condition cleans up
Remove File    /tmp/subscriber_ip.txt
```

### Solution 2: Synchronization Files

```robot
# Pre-condition creates flag
Create File    /tmp/setup_done.txt    done

# Parallel tests wait for flag
File Should Exist    /tmp/setup_done.txt

# Better: Wait with retry
Wait Until Keyword Succeeds    30s    1s    File Should Exist    /tmp/setup_done.txt
```

### Solution 3: Shared Variables in Test Execution Order

```
Pre-condition captures and stores data
    ↓
Parallel tests read stored data
    ↓
Post-condition cleans up
```

### Best Practices

✅ Use `/tmp/` for temporary files (cross-process)
✅ Use absolute paths, not relative
✅ Clean up files in post-condition
✅ Use `Wait Until Keyword Succeeds` for synchronization
✅ Add timestamps to files for debugging

❌ Don't rely on test variables (isolated per process)
❌ Don't use relative paths
❌ Don't forget cleanup
❌ Don't hardcode IPs or credentials

---

## Real-World Examples

### Example 1: Simple Parallel Tests (No State Sharing)

```bash
# Just run tests in parallel, no special setup
pabot --testlevelsplit --processes 3 Tests/Logging.robot
```

### Example 2: Parallel with Pre-Condition Setup

```bash
# Run with custom ordering
pabot --ordering A1_Ordering.txt --testlevelsplit --processes 3 Tests/A1/
```

**A1_Ordering.txt**:
```
--suite A1.A1.Setup
{
    --test A1.A2.Test1
    --test A1.A2.Test2
    --test A1.A2.Test3
}
--suite A1.A3.Cleanup
```

### Example 3: Production Jenkins Pipeline

```bash
#!/bin/bash
BUILD_ID=$1
RESULTS_DIR="Results_${BUILD_ID}"

pabot --testlevelsplit --processes 6 \
      --loglevel TRACE \
      --outputdir "${RESULTS_DIR}" \
      --log Health_Check_${BUILD_ID}_Log.html \
      --report Health_Check_${BUILD_ID}_Report.html \
      --output Health_Check_${BUILD_ID}_output.xml \
      --include parallel \
      Tests/

# Exit with test result status
exit $?
```

### Example 4: Parallel with Resource Cleanup

```robot
*** Settings ***
Resource    Common.robot
Library     OperatingSystem
Suite Teardown    Cleanup All Temp Files

*** Test Cases ***
Test 1    [Tags]    parallel
    Create Resource    /tmp/resource_1.txt
    Use Resource       /tmp/resource_1.txt

Test 2    [Tags]    parallel
    Create Resource    /tmp/resource_2.txt
    Use Resource       /tmp/resource_2.txt

*** Keywords ***
Cleanup All Temp Files
    Remove Files    /tmp/resource_*.txt
```

---

## Troubleshooting

### Issue 1: Ordering Items Skipped

**Error**:
```
Note: The ordering file contains test or suite items that are 
not included in the current test run. The following items will be ignored:
  - Test item: 'A1.A2.Execute Radius Command...'
```

**Cause**: Test name in ordering file doesn't match actual test name

**Solution**:
```bash
# Get actual test names
robot --dryrun --loglevel DEBUG Tests/A1

# Update A1_Ordering.txt with exact names
```

### Issue 2: FileNotFoundError During Parallel Tests

**Error**:
```
FileNotFoundError: [Errno 2] No such file or directory: '/tmp/subscriber_ip.txt'
```

**Cause**: Pre-condition didn't complete before parallel tests started

**Solution**:
```robot
# Ensure proper ordering
--suite A1.PreCondition
{
    --test A1.MainTest1
}

# Use Wait Until in parallel tests
Wait Until Created    /tmp/subscriber_ip.txt    timeout=30s
```

### Issue 3: Tests Pass Sequentially but Fail in Parallel

**Cause**: Race conditions or shared resource conflicts

**Solution**:
```robot
# Add unique identifiers
${pid}=    Get Process ID
${resource}=    Set Variable    /tmp/resource_${pid}.txt

# Use file locks
Acquire Lock    /tmp/test.lock
# ... critical section ...
Release Lock    /tmp/test.lock

# Add delays
Sleep    1s    # Allow other processes to complete
```

### Issue 4: Uneven Process Distribution

**Problem**: Some processes finish early, others lag

**Solution**: Use `--testlevelsplit` instead of suite-level split
```bash
# Better distribution
pabot --testlevelsplit --processes 3 Tests/

# Avoid this (uneven)
pabot --processes 3 Tests/
```

### Issue 5: Suite Setup Runs Multiple Times

**Problem**: Suite Setup executes for each process

**Solution**: Move to pre-condition test
```robot
# DON'T: Runs 3 times
Suite Setup    Setup Radius And Add IP

# DO: Runs 1 time
*** Test Cases ***
Initialize Environment
    Setup Radius And Add IP
```

---

## Performance Optimization

### Optimal Process Count

```
Processes    Execution Time    Speedup    Recommended
1            60 min            1x         Sequential baseline
2            35 min            1.7x       Use if 2 cores
3            20 min            3x         ⭐ BEST
4            18 min            3.3x       ⭐ GOOD
5            17 min            3.5x       Diminishing returns
6            17 min            3.5x       Over-provisioned
```

**Recommendation**: Use 3-4 processes (best speedup with low overhead)

### Tips for Better Performance

1. **Use Test-Level Split**
   ```bash
   pabot --testlevelsplit --processes 3 Tests/
   ```

2. **Reduce Logging in Parallel**
   ```bash
   pabot --testlevelsplit --processes 3 --loglevel INFO Tests/
   ```

3. **Minimize Setup Time**
   - Move expensive operations to pre-condition
   - Reuse connections when possible
   - Cache credentials

4. **Balance Test Duration**
   - Mix fast and slow tests across processes
   - Avoid grouping slow tests together

---

## Summary Checklist

✅ Create test structure: A1 (setup) → A2 (tests) → A3 (cleanup)
✅ Tag parallel tests with `[Tags]    parallel`
✅ Use file-based state sharing between processes
✅ Create A1_Ordering.txt for execution control
✅ Run with `pabot --testlevelsplit --processes 3`
✅ Use `Wait Until Keyword Succeeds` for synchronization
✅ Clean up temp files in post-condition
✅ Test with sequential first (`robot ...`)
✅ Verify output in Results/ directory
✅ Monitor for race conditions

---

**Last Updated**: February 2026
**Version**: 1.0
**Maintainer**: Chirag Dhingra (cdhingra@akamai.com)
