*** Settings ***
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot



*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for MEL
    [Documentation]    - MEL Health Check Script Component- DCR
    [Tags]    Parallel MEL
    DCR Services Check    ${MEL}

ABR Services Check for MEL
    [Documentation]    - MEL Health Check Script Component- ABR
    [Tags]    Parallel MEL
    ABR Services Check    ${MEL}

XEPA Services Check for MEL
    [Documentation]    - MEL Health Check Script Component- XEPA
    [Tags]    Parallel MEL
    XEPA Services Check    ${MEL}

COL Services Check for MEL
    [Documentation]    - MEL Health Check Script Component- COL
    [Tags]    Parallel MEL
    COL Services Check    ${MEL}

CIBR Services Check for MEL
   [Documentation]    - MEL Health Check Script Component- CIBR
   [Tags]    Parallel MEL
   CIBR Services Check    ${MEL}

AAA Services Check for MEL
   [Documentation]    - MEL Health Check Script Component- AAA
   [Tags]    Parallel MEL
   AAA Services Check    ${MEL}

RSX Services Check for MEL
   [Documentation]    - MEL Health Check Script Component- RSX
   [Tags]    Parallel MEL
   RSX Services Check    ${MEL}

PROD-PRX Services Check for MEL
   [Documentation]    - MEL Health Check Script Component- PROD-PRX
   [Tags]    Parallel MEL
   PROD Services Check    ${MEL}

VPNAT Services Check for MEL
   [Documentation]    - MEL Health Check Script Component- VPNAT
   [Tags]    Parallel MEL
   VPNNAT Services Check    ${MEL}
