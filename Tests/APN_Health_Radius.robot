*** Settings ***
Library    OperatingSystem
Resource    ../Resources/A1_Pabot_POC.robot


*** Test Cases ***
Execute Radius Command for in simulator for APN Healthcheck
    [Tags]    parallel
    Establish Radius Command in AAA Simulator APN Healthcheck

Execute Browse test in simulator for APN Healthcheck
    [Tags]    parallel
    Browse Test Through UE Simulator

Check Client Latch
    [Tags]    parallel
    ${abr}    ${ip}=    Get Client Latch From ABR-FRA08-05 Or ABR-FRA08-06
    Log    Latch result: ${abr} -> ${ip}