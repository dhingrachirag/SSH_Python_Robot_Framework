*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for HKG
    [Documentation]    - HKG Health Check Script Component- DCR
    DCR Services Check    ${HKG}

ABR Services Check for HKG
    [Documentation]    - HKG Health Check Script Component- ABR
    ABR Services Check    ${HKG}

XEPA Services Check for HKG
    [Documentation]    - HKG Health Check Script Component- XEPA
    XEPA Services Check    ${HKG}

COL Services Check for HKG
    [Documentation]    - HKG Health Check Script Component- COL
    COL Services Check    ${HKG}

CIBR Services Check for HKG
   [Documentation]    - HKG Health Check Script Component- CIBR
   CIBR Services Check    ${HKG}

AAA Services Check for HKG
   [Documentation]    - HKG Health Check Script Component- AAA
   AAA Services Check    ${HKG}

RSX Services Check for HKG
   [Documentation]    - HKG Health Check Script Component- RSX
   RSX Services Check    ${HKG}

PROD-PRX Services Check for HKG
   [Documentation]    - HKG Health Check Script Component- PROD-PRX
   PROD Services Check    ${HKG}

WCS Services Check for HKG
   [Documentation]    - HKG Health Check Script Component- WCS
   WCS Services Check    ${HKG}

VPNAT Services Check for HKG
   [Documentation]    - HKG Health Check Script Component- VPNAT
   VPNNAT Services Check    ${HKG}


