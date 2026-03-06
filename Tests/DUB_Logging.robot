*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for DUB
    [Documentation]    - DUB Health Check Script Component- DCR
    DCR Services Check    ${DUB}

ABR Services Check for DUB
    [Documentation]    - DUB Health Check Script Component- ABR
    ABR Services Check    ${DUB}

XEPA Services Check for DUB
    [Documentation]    - DUB Health Check Script Component- XEPA
    XEPA Services Check    ${DUB}

COL Services Check for DUB
    [Documentation]    - DUB Health Check Script Component- COL
    COL Services Check    ${DUB}

CIBR Services Check for DUB
   [Documentation]    - DUB Health Check Script Component- CIBR
   CIBR Services Check    ${DUB}

AAA Services Check for DUB
   [Documentation]    - DUB Health Check Script Component- AAA
   AAA Services Check    ${DUB}

RSX Services Check for DUB
   [Documentation]    - DUB Health Check Script Component- RSX
   RSX Services Check    ${DUB}

PROD-PRX Services Check for DUB
   [Documentation]    - DUB Health Check Script Component- PROD-PRX
   PROD Services Check    ${DUB}

#WCS Services Check for DUB
#   [Documentation]    - DUB Health Check Script Component- WCS
#   WCS Services Check    ${DUB}

VPNAT Services Check for DUB
   [Documentation]    - DUB Health Check Script Component- VPNAT
   VPNNAT Services Check    ${DUB}
