# Troubleshooting & Best Practices Guide

## Table of Contents
1. [Common Errors & Fixes](#common-errors--fixes)
2. [SSH Connection Issues](#ssh-connection-issues)
3. [Parallel Execution Problems](#parallel-execution-problems)
4. [Best Practices](#best-practices)
5. [Performance Tuning](#performance-tuning)

---

## Common Errors & Fixes

### Error 1: "File Should Exist" Ambiguity

**Problem**:
```
Keyword 'File Should Exist' found both from a custom library 'SSHLibrary' 
and a standard library 'OperatingSystem'. The custom keyword is used.
```

**Why It Happens**: Both SSHLibrary and OperatingSystem provide the same keyword

**Solution**:
```robot
# DON'T: Ambiguous (Robot picks one randomly)
File Should Exist    /path/to/file

# DO: Explicit library
OperatingSystem.File Should Exist    /path/to/file

# For SSH files
SSHLibrary.File Should Exist    /path/to/remote/file
```

**Both in one test**:
```robot
*** Keywords ***
Check Local And Remote Files
    OperatingSystem.File Should Exist    /tmp/local_file.txt
    SSHLibrary.File Should Exist    /remote/server/file.txt
```

---

### Error 2: SSHLibrary Keyword Expects Wrong Argument Count

**Problem**:
```
Keyword 'SSHLibrary.File Should Exist' expected 1 argument, got 2.
```

**Why It Happens**: SSHLibrary.File Should Exist takes full path, not separate parts

**Wrong Usage**:
```robot
# This fails - passing 2 arguments
SSHLibrary.File Should Exist    /tmp    myfile.txt
```

**Correct Usage**:
```robot
# Pass full path as single argument
SSHLibrary.File Should Exist    /tmp/myfile.txt

# Or with variables
${full_path}=    Catenate    /tmp    /    myfile.txt
SSHLibrary.File Should Exist    ${full_path}
```

---

### Error 3: Suite Setup Executes Multiple Times in Parallel

**Problem**: Suite Setup runs 3 times with 3 parallel processes

**Why It Happens**: Each process instance runs its own Suite Setup

**DON'T DO THIS**:
```robot
*** Settings ***
Suite Setup    Setup Radius And Add IP    # Runs 3 times!
Suite Teardown    Cleanup Resources       # Runs 3 times!

*** Test Cases ***
Test 1    [Tags]    parallel
    # Test code

Test 2    [Tags]    parallel
    # Test code
```

**DO THIS INSTEAD**:
```robot
# In A1.robot (pre-condition)
*** Test Cases ***
Initialize Environment
    [Documentation]    Setup runs ONCE
    Setup Radius And Add IP
    
# In A2.robot (main tests)
*** Test Cases ***
Test 1    [Tags]    parallel
    # Test code (uses pre-condition setup)

Test 2    [Tags]    parallel
    # Test code (uses pre-condition setup)

# In A3.robot (post-condition)
*** Test Cases ***
Cleanup Environment
    [Documentation]    Cleanup runs ONCE
    Cleanup Resources
```

---

### Error 4: FileNotFoundError in Parallel Tests

**Problem**:
```
FileNotFoundError: [Errno 2] No such file or directory: '/tmp/subscriber_ip.txt'
```

**Why It Happens**:
- Pre-condition didn't complete before parallel tests started
- File doesn't exist yet
- Using relative paths

**Solution**:

```robot
# Pre-condition (A1.robot)
*** Test Cases ***
Initialize Environment
    ${Subscriber_IP}=    Establish Radius Command
    Create File    /tmp/subscriber_ip.txt    ${Subscriber_IP}
    Log    File created with IP

# Parallel test (A2.robot)
*** Test Cases ***
My Parallel Test
    [Tags]    parallel
    
    # CORRECT: Wait for file to be created
    Wait Until Keyword Succeeds    30s    1s    File Should Exist    /tmp/subscriber_ip.txt
    
    ${IP}=    Get File    /tmp/subscriber_ip.txt
    ${IP}=    Strip String    ${IP}
    Log    Using IP: ${IP}
```

**Best Practice**:
```robot
# Create synchronization file
Create File    /tmp/setup_complete.txt    done

# Parallel tests wait
Wait Until Keyword Succeeds    
    timeout=30s
    retry_interval=1s
    Condition    File Should Exist    /tmp/setup_complete.txt

# Then proceed
${data}=    Get File    /tmp/data_file.txt
```

---

### Error 5: pabot.PabotLib not found

**Problem**:
```
No module named 'pabot.PabotLib'
Library    pabot.PabotLib    # Not found!
```

**Why It Happens**: 
- PAbOT not properly installed
- Using old/incorrect library syntax

**Solution**:
```bash
# Install PAbOT correctly
pip install robotframework-pabot

# Verify installation
pabot --version
```

**In Robot Files** (for parallel-aware utilities):
```robot
Library    OperatingSystem
Library    Collections

# DON'T use pabot.PabotLib for regular tests
# PAbOT functionality is automatic

# For parallel tests, just use file-based communication
Create File    /tmp/shared_data.txt    data
${data}=    Get File    /tmp/shared_data.txt
```

---

## SSH Connection Issues

### Issue 1: SSH Timeout

**Problem**: `SSHLibrary.Read Until: timeout exceeded`

**Why It Happens**:
- Server responding slowly
- Network latency
- Default timeout too short

**Solution**:

```robot
# Increase timeout
Read Until    prompt    timeout=30s

# Or with explicit delay
Read Until    expected_output    delay=2s

# With longer retry
${max_time}=    Convert Time    30s    result_format=number
${result}=    Run Keyword And Return Status    Read Until    prompt    timeout=30s
```

**Best Practice**:
```robot
*** Keywords ***
Read Until Prompt With Retry
    [Arguments]    ${expected}    ${timeout}=30s    ${retries}=3
    FOR    ${i}    RANGE    ${retries}
        ${status}=    Run Keyword And Return Status    
        ...    Read Until    ${expected}    timeout=${timeout}
        
        IF    ${status}
            BREAK
        ELSE
            Log    Retry ${i} failed, waiting before retry    level=WARN
            Sleep    2s
        END
    END
    
    Should Be True    ${status}    Failed to read after ${retries} retries
```

---

### Issue 2: Connection Refused

**Problem**: `[Errno 111] Connection refused`

**Why It Happens**:
- SSH service not running on target
- Wrong IP/port
- Firewall blocking

**Solution**:
```robot
*** Keywords ***
Establish Connection With Verification
    [Arguments]    ${host}    ${port}=22
    
    # Verify connectivity first
    ${ping_status}=    Run Keyword And Return Status    
    ...    Execute Command    ping -c 1 ${host}
    
    Should Be True    ${ping_status}    
    ...    Cannot ping ${host} - check network connectivity
    
    # Then try SSH
    Open Connection    ${host}    port=${port}
    
    Log    Connected to ${host}:${port}
```

---

### Issue 3: Authentication Failed

**Problem**: `Authentication failed`

**Why It Happens**:
- Wrong credentials
- Password changed
- SSH key issues

**Solution**:
```robot
*** Keywords ***
Establish Secure Connection
    [Arguments]    ${host}    ${username_encrypted}    ${password_encrypted}
    
    ${username}=    Get Decrypted Text    ${username_encrypted}
    ${password}=    Get Decrypted Text    ${password_encrypted}
    
    # Log attempt (without exposing password)
    Log    Attempting login to ${host} as ${username}
    
    TRY
        Open Connection    ${host}
        Login    ${username}    ${password}
        Log    Successfully logged in
    EXCEPT    *
        Log    Authentication failed - check credentials    level=ERROR
        Fail    Could not authenticate with provided credentials
    END
```

---

## Parallel Execution Problems

### Issue 1: Tests Pass Sequentially but Fail in Parallel

**Problem**: Sequential execution is fine, but parallel execution fails

**Why It Happens**: Race conditions on shared resources

**Debugging Steps**:
```bash
# Step 1: Run sequentially to establish baseline
robot Tests/A1/A2.robot

# Step 2: Run with detailed logging
pabot --loglevel TRACE --processes 1 Tests/A1/

# Step 3: Run parallel and compare logs
pabot --loglevel TRACE --processes 3 Tests/A1/
```

**Common Causes & Fixes**:
```robot
# PROBLEM 1: Multiple processes modifying same resource
# SOLUTION: Use unique resource names per process
${process_id}=    Get Process ID
${file}=    Set Variable    /tmp/resource_${process_id}.txt

# PROBLEM 2: Race condition on file creation
# SOLUTION: Use file locks or atomic operations
File Should Exist    /tmp/lock_file.txt    # Wait for other process
Create File    /tmp/lock_file.txt    locked
# ... do work ...
Remove File    /tmp/lock_file.txt

# PROBLEM 3: SSH connection conflicts
# SOLUTION: Use unique sessions per test
Open Connection    ${host}    alias=test_${process_id}
# ... work ...
Close Connection    alias=test_${process_id}
```

---

### Issue 2: Ordering File Items Ignored/Skipped

**Problem**:
```
Note: The ordering file contains test or suite items that are not 
included in the current test run. Items will be ignored:
  - Test item: 'A1.A2.Execute Radius Command...'
```

**Why It Happens**: Test name in ordering file doesn't match actual test

**Solution**:
```bash
# Step 1: Get actual test structure
robot --dryrun --loglevel DEBUG Tests/A1 > test_structure.txt

# Step 2: Check output for exact test paths
# Look for test names like: A1.A1, A1.A2, A1.A3
cat test_structure.txt | grep "Test Name"

# Step 3: Update A1_Ordering.txt with EXACT names
```

**Example Fix**:
```
# WRONG (doesn't match actual test names)
--suite A1 Par Structure.A1 Pre Condition
--test A1 Par Structure.A1 PAR POC Production.Execute Radius Command

# RIGHT (matches dryrun output exactly)
--suite A1.A1.Initialize Environment
--test A1.A2.Execute Radius Command for in simulator for APN Healthcheck
```

---

### Issue 3: Uneven Process Distribution

**Problem**: Some processes finish early, others take much longer

**Cause**: Using suite-level split instead of test-level

**Solution**:
```bash
# Use test-level split (better distribution)
pabot --testlevelsplit --processes 3 Tests/

# Avoid suite-level split
# pabot --processes 3 Tests/  # SLOWER, uneven
```

---

## Best Practices

### 1. Code Organization

```robot
*** Settings ***
# Keep settings concise
Resource    ../Resources/Common.robot
Library     OperatingSystem
Library     Collections

*** Variables ***
# Use clear names
${HOST}           localhost
${SSH_PORT}       22
${TIMEOUT}        30s

*** Keywords ***
# One keyword = one responsibility
Establish SSH Connection
    [Arguments]    ${host}    ${username}    ${password}
    Open Connection    ${host}    port=${SSH_PORT}
    Login    ${username}    ${password}

Execute Remote Command Safely
    [Arguments]    ${command}
    TRY
        ${result}=    Execute Command    ${command}
        RETURN    ${result}
    EXCEPT    *
        Log    Command failed: ${command}    level=ERROR
        Fail    Remote command execution failed
    END

*** Test Cases ***
# Clear test names, single purpose
My First Test
    [Documentation]    Clear description of what's being tested
    [Tags]    parallel
    
    Establish SSH Connection    ${HOST}    ${USERNAME}    ${PASSWORD}
    Execute Remote Command Safely    ls -la
    Close All Connections
```

---

### 2. Error Handling

```robot
*** Keywords ***
Check Service Status With Fallback
    [Arguments]    ${service_name}
    
    # Try primary method
    ${status}=    Run Keyword And Return Status    
    ...    Execute Command    systemctl status ${service_name}
    
    IF    not ${status}
        # Fallback to alternative check
        ${status}=    Run Keyword And Return Status    
        ...    Execute Command    ps aux | grep ${service_name}
        
        Should Be True    ${status}    Service ${service_name} not found
    END
    
    Log    ${service_name} is running

Robust Test Execution
    [Arguments]    ${keyword}    @{args}
    
    TRY
        Run Keyword    ${keyword}    @{args}
    EXCEPT    AssertionError AS ${error}
        Log    Test assertion failed: ${error}    level=ERROR
        Fail    ${error}
    EXCEPT    *
        Log    Unexpected error: ${error}    level=ERROR
        Fail    Unexpected error occurred
    FINALLY
        # Always cleanup
        Close All Connections
    END
```

---

### 3. Variable Management

```robot
*** Settings ***
Resource    ../Variables/globalvariables.robot
Resource    ../Variables/Authentication_variables.robot

*** Keywords ***
Get Credentials Safely
    [Arguments]    ${service}
    
    # Don't log credentials!
    ${username}=    Get Decrypted Text    ${${service}_USERNAME}
    ${password}=    Get Decrypted Text    ${${service}_PASSWORD}
    
    Log    Using credentials for ${service}    level=INFO
    
    RETURN    ${username}    ${password}

Use Temporary Variables
    # Create temporary file for IPC (Inter-Process Communication)
    ${temp_dir}=    Set Variable    /tmp/robot_test_$$
    Create Directory    ${temp_dir}
    
    # Use during test
    Create File    ${temp_dir}/test_data.txt    some_data
    
    # Cleanup
    Remove Directory    ${temp_dir}    recursive=True
```

---

### 4. Logging Best Practices

```robot
*** Keywords ***
Log Operation Sequence
    [Arguments]    ${operation_name}
    
    # Use consistent format
    Log    [START] ${operation_name}    level=INFO
    
    TRY
        # Perform operation
        Log    [IN PROGRESS] ${operation_name}    level=DEBUG
        # ... code ...
        Log    [SUCCESS] ${operation_name}    level=INFO
    EXCEPT
        Log    [FAILED] ${operation_name}    level=ERROR
        FAIL    ${operation_name} failed
    END

Log With Context
    [Arguments]    ${message}    ${context}={}
    
    # Include relevant context
    ${timestamp}=    Get Current Date    result_format=%H:%M:%S
    Log    [${timestamp}] ${message} | Context: ${context}
```

---

## Performance Tuning

### 1. Optimal Process Count

```bash
# Test with different process counts
for proc in 1 2 3 4 5; do
    echo "Testing with $proc processes..."
    pabot --processes $proc \
          --loglevel INFO \
          --outputdir Results_${proc} \
          Tests/
done
```

**Expected Results**:
```
1 process:  60 minutes
2 processes: 35 minutes (1.7x speedup)
3 processes: 20 minutes (3x speedup) ⭐ BEST
4 processes: 18 minutes (3.3x speedup)
5+ processes: 17 minutes (diminishing returns)
```

---

### 2. Connection Reuse

```robot
*** Keywords ***
Execute Multiple Commands Efficiently
    [Arguments]    @{commands}
    
    # GOOD: Open once, execute multiple
    Open Connection    ${host}
    Login    ${username}    ${password}
    
    FOR    ${cmd}    IN    @{commands}
        ${result}=    Execute Command    ${cmd}
        Log    ${result}
    END
    
    Close All Connections

Wrong Approach
    # BAD: Open/close for each command (slow!)
    FOR    ${cmd}    IN    @{commands}
        Open Connection    ${host}
        Login    ${username}    ${password}
        Execute Command    ${cmd}
        Close All Connections
    END
```

---

### 3. Logging Optimization

```bash
# For CI/CD: Use INFO level (faster)
pabot --loglevel INFO --processes 3 Tests/

# For debugging: Use TRACE level (slower, more detail)
pabot --loglevel TRACE --processes 1 Tests/

# For final reports: Use default (good balance)
pabot --processes 3 Tests/
```

---

## Summary Checklist

### Before Running Tests
- ✅ Update Authentication_variables.robot with real credentials
- ✅ Verify network connectivity to target hosts
- ✅ Check SSH access works manually first
- ✅ Review test tags and ordering configuration

### Running Tests
- ✅ Start with sequential test (`robot ...`)
- ✅ Verify results and logs
- ✅ Then run parallel (`pabot --testlevelsplit --processes 3 ...`)
- ✅ Monitor for race conditions

### After Tests
- ✅ Check Results/ for HTML reports
- ✅ Review any failed tests
- ✅ Clean up temporary files
- ✅ Archive results for history

### Parallel Execution Specifics
- ✅ Use pre-condition/main/post-condition pattern
- ✅ Tag parallel tests with `[Tags]    parallel`
- ✅ Use file-based shared state
- ✅ Wait for synchronization files
- ✅ Clean up in post-condition
- ✅ Use --testlevelsplit (not suite-level)
- ✅ 3-4 processes optimal

---

**Last Updated**: February 2026
**Version**: 1.0
**Maintainer**: Chirag Dhingra (cdhingra@akamai.com)
