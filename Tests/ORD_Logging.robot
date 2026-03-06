*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for ORD
    [Documentation]    - ORD Health Check Script Component- DCR
    DCR Services Check    ${ORD}

ABR Services Check for ORD
    [Documentation]    - ORD Health Check Script Component- ABR
    ABR Services Check    ${ORD}

XEPA Services Check for ORD
    [Documentation]    - ORD Health Check Script Component- XEPA
    XEPA Services Check    ${ORD}

COL Services Check for ORD
    [Documentation]    - ORD Health Check Script Component- COL
    COL Services Check    ${ORD}

CIBR Services Check for ORD
   [Documentation]    - ORD Health Check Script Component- CIBR
   CIBR Services Check    ${ORD}

AAA Services Check for ORD
   [Documentation]    - ORD Health Check Script Component- AAA
   AAA Services Check    ${ORD}

RSX Services Check for ORD
   [Documentation]    - ORD Health Check Script Component- RSX
   RSX Services Check    ${ORD}

PROD-PRX Services Check for ORD
   [Documentation]    - ORD Health Check Script Component- PROD-PRX
   PROD Services Check    ${ORD}

#WCS Services Check for ORD
#   [Documentation]    - ORD Health Check Script Component- WCS
#   WCS Services Check    ${ORD}

VPNAT Services Check for ORD
   [Documentation]    - ORD Health Check Script Component- VPNAT
   VPNNAT Services Check    ${ORD}
