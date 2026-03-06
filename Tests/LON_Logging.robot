*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for LON
    [Documentation]    - LON Health Check Script Component- DCR
    DCR Services Check    ${LON}

ABR Services Check for LON
    [Documentation]    - LON Health Check Script Component- ABR
    ABR Services Check    ${LON}

XEPA Services Check for LON
    [Documentation]    - LON Health Check Script Component- XEPA
    XEPA Services Check    ${LON}

COL Services Check for LON
    [Documentation]    - LON Health Check Script Component- COL
    COL Services Check    ${LON}

CIBR Services Check for LON
   [Documentation]    - LON Health Check Script Component- CIBR
   CIBR Services Check    ${LON}

AAA Services Check for LON
   [Documentation]    - LON Health Check Script Component- AAA
   AAA Services Check    ${LON}

RSX Services Check for LON
   [Documentation]    - LON Health Check Script Component- RSX
   RSX Services Check    ${LON}

PROD-PRX Services Check for LON
   [Documentation]    - LON Health Check Script Component- PROD-PRX
   PROD Services Check    ${LON}

#WCS Services Check for LON
#   [Documentation]    - LON Health Check Script Component- WCS
#   WCS Services Check    ${LON}
#
VPNAT Services Check for LON
   [Documentation]    - LON Health Check Script Component- VPNAT
   VPNNAT Services Check    ${LON}


