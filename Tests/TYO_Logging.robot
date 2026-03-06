*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for TYO
    [Documentation]    - TYO Health Check Script Component- DCR
    DCR Services Check    ${TYO}

ABR Services Check for TYO
    [Documentation]    - TYO Health Check Script Component- ABR
    ABR Services Check    ${TYO}

XEPA Services Check for TYO
    [Documentation]    - TYO Health Check Script Component- XEPA
    XEPA Services Check    ${TYO}

COL Services Check for TYO
    [Documentation]    - TYO Health Check Script Component- COL
    COL Services Check    ${TYO}

CIBR Services Check for TYO
   [Documentation]    - TYO Health Check Script Component- CIBR
   CIBR Services Check    ${TYO}

AAA Services Check for TYO
   [Documentation]    - TYO Health Check Script Component- AAA
   AAA Services Check    ${TYO}

RSX Services Check for TYO
   [Documentation]    - TYO Health Check Script Component- RSX
   RSX Services Check    ${TYO}

PROD-PRX Services Check for TYO
   [Documentation]    - TYO Health Check Script Component- PROD-PRX
   PROD Services Check    ${TYO}

#WCS Services Check for TYO
#   [Documentation]    - TYO Health Check Script Component- WCS
#   WCS Services Check    ${TYO}

VPNAT Services Check for TYO
   [Documentation]    - TYO Health Check Script Component- VPNAT
   VPNNAT Services Check    ${TYO}