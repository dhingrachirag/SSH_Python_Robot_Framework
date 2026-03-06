*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot


*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for LAX
    [Documentation]    - LAX Health Check Script Component- DCR
    DCR Services Check    ${LAX}

ABR Services Check for LAX
    [Documentation]    - LAX Health Check Script Component- ABR
    ABR Services Check    ${LAX}

XEPA Services Check for LAX
    [Documentation]    - LAX Health Check Script Component- XEPA
    XEPA Services Check    ${LAX}

CIBR Services Check for LAX
   [Documentation]    - LAX Health Check Script Component- CIBR
   CIBR Services Check    ${LAX}

RSX Services Check for LAX
   [Documentation]    - LAX Health Check Script Component- RSX
   RSX Services Check    ${LAX}

#WCS Services Check for LAX
#   [Documentation]    - LAX Health Check Script Component- WCS
#   WCS Services Check    ${LAX}

COL Services Check for LAX
    [Documentation]    - LAX Health Check Script Component- COL
    COL Services Check    ${LAX}

AAA Services Check for LAX
   [Documentation]    - LAX Health Check Script Component- AAA
   AAA Services Check    ${LAX}

PROD-PRX Services Check for LAX
   [Documentation]    - LAX Health Check Script Component- PROD-PRX
   PROD Services Check    ${LAX}

VPNAT Services Check for LAX
   [Documentation]    - LAX Health Check Script Component- VPNAT
   VPNNAT Services Check    ${LAX}