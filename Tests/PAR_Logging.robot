*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for PAR
    [Documentation]    - PAR Health Check Script Component- DCR
    DCR Services Check    ${PAR}

ABR Services Check for PAR
    [Documentation]    - PAR Health Check Script Component- ABR
    ABR Services Check    ${PAR}

XEPA Services Check for PAR
    [Documentation]    - PAR Health Check Script Component- XEPA
    XEPA Services Check    ${PAR}

COL Services Check for PAR
    [Documentation]    - PAR Health Check Script Component- COL
    COL Services Check    ${PAR}

CIBR Services Check for PAR
   [Documentation]    - PAR Health Check Script Component- CIBR
   CIBR Services Check    ${PAR}

AAA Services Check for PAR
   [Documentation]    - PAR Health Check Script Component- AAA
   AAA Services Check    ${PAR}

RSX Services Check for PAR
   [Documentation]    - PAR Health Check Script Component- RSX
   RSX Services Check    ${PAR}

PROD-PRX Services Check for PAR
   [Documentation]    - PAR Health Check Script Component- PROD-PRX
   PROD Services Check    ${PAR}

#WCS Services Check for PAR
#   [Documentation]    - PAR Health Check Script Component- WCS
#   WCS Services Check    ${PAR}

VPNAT Services Check for PAR
   [Documentation]    - PAR Health Check Script Component- VPNAT
   VPNNAT Services Check    ${PAR}