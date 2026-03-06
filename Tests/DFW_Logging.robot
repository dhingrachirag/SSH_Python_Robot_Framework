*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for DFW
    [Documentation]    - DFW Health Check Script Component- DCR
    DCR Services Check    ${DFW}

ABR Services Check for DFW
    [Documentation]    - DFW Health Check Script Component- ABR
    ABR Services Check    ${DFW}

XEPA Services Check for DFW
    [Documentation]    - DFW Health Check Script Component- XEPA
    XEPA Services Check    ${DFW}

COL Services Check for DFW
    [Documentation]    - DFW Health Check Script Component- COL
    COL Services Check    ${DFW}

CIBR Services Check for DFW
   [Documentation]    - DFW Health Check Script Component- CIBR
   CIBR Services Check    ${DFW}

AAA Services Check for DFW
   [Documentation]    - DFW Health Check Script Component- AAA
   AAA Services Check    ${DFW}

RSX Services Check for DFW
   [Documentation]    - DFW Health Check Script Component- RSX
   RSX Services Check    ${DFW}

PROD-PRX Services Check for DFW
   [Documentation]    - DFW Health Check Script Component- PROD-PRX
   PROD Services Check    ${DFW}

#WCS Services Check for DFW
#   [Documentation]    - DFW Health Check Script Component- WCS
#   WCS Services Check    ${DFW}

VPNAT Services Check for DFW
   [Documentation]    - DFW Health Check Script Component- VPNAT
   VPNNAT Services Check    ${DFW}