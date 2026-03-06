*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for EWR
    [Documentation]    - EWR Health Check Script Component- DCR
    DCR Services Check    ${EWR}

ABR Services Check for EWR
    [Documentation]    - EWR Health Check Script Component- ABR
    ABR Services Check    ${EWR}

XEPA Services Check for EWR
    [Documentation]    - EWR Health Check Script Component- XEPA
    XEPA Services Check    ${EWR}

COL Services Check for EWR
    [Documentation]    - EWR Health Check Script Component- COL
    COL Services Check    ${EWR}

CIBR Services Check for EWR
   [Documentation]    - EWR Health Check Script Component- CIBR
   CIBR Services Check    ${EWR}

AAA Services Check for EWR
   [Documentation]    - EWR Health Check Script Component- AAA
   AAA Services Check    ${EWR}

RSX Services Check for EWR
   [Documentation]    - EWR Health Check Script Component- RSX
   RSX Services Check    ${EWR}

PROD-PRX Services Check for EWR
   [Documentation]    - EWR Health Check Script Component- PROD-PRX
   PROD Services Check    ${EWR}

#WCS Services Check for EWR
#   [Documentation]    - EWR Health Check Script Component- WCS
#   WCS Services Check    ${EWR}

VPNAT Services Check for EWR
   [Documentation]    - EWR Health Check Script Component- VPNAT
   VPNNAT Services Check    ${EWR}


