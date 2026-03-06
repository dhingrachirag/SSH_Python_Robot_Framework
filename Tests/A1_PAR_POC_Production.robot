#*** Settings ***
#Library    OperatingSystem
#Resource    ../Resources/APN_PAR01_POC.robot
#Library    pabot.PabotLib
#Suite Setup       Setup Radius And Add IP
#Suite Teardown    Delete Client IP from GI interface post test
#
#
#*** Test Cases ***
#Execute Radius Command for in simulator for APN Healthcheck
#    [Tags]    parallel
#    Run Radius Command Parallel
#
#Browse Test Through UE Simulator Parallel
#    [Tags]    parallel
#    Browse UE Parallel
#
#Check Client Latch Parallel
#    [Tags]    parallel
#    Check Client Latch Parallel

*** Settings ***
Library    OperatingSystem
Library    pabot.PabotLib
Resource    ../Resources/APN_PAR01_POC.robot

## Mandatory: Login in every process so SSH works
#Test Setup    UE-Simulator Login

*** Test Cases ***
# --- PROCESS 1: SETUP ---
Execute Radius Command and Add IP
    [Tags]    parallel
    [Documentation]    Step 1 & 2: Get IP, Configure Interface, Signal READY.
    Execute Radius And Setup IP

# --- PROCESS 2: TRAFFIC (RADIUS AGAIN) ---
Run Radius Traffic Parallel
    [Tags]    parallel
    [Documentation]    Runs Radius command again in parallel, WITHOUT adding IP.
    Execute Radius Traffic Only

# --- PROCESS 3: BROWSE ---
Browse Test Through UE Simulator Parallel
    [Tags]    parallel
    [Documentation]    Step 3: Wait for IP, then Browse.
    Browse UE Parallel

# --- PROCESS 4: LATCH ---
Check Client Latch Parallel
    [Tags]    parallel
    [Documentation]    Step 4: Wait for IP, then Check Latch.
    Check Client Latch Parallel

# --- PROCESS 5: CLEANUP ---
Cleanup Client IP Post Test
    [Tags]    parallel
    [Documentation]    Step 5: Wait for others to finish, then cleanup.
    Cleanup Client IP Parallel