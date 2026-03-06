*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for LON02
    [Documentation]    - LON02 Health Check Script Component- DCR
    DCR Services Check    ${LON02}

ABR Services Check for LON02
    [Documentation]    - LON02 Health Check Script Component- ABR
    ABR Services Check    ${LON02}

XEPA Services Check for LON02
    [Documentation]    - LON02 Health Check Script Component- XEPA
    XEPA Services Check    ${LON02}

COL Services Check for LON02
    [Documentation]    - LON02 Health Check Script Component- COL
    COL Services Check    ${LON02}

CIBR Services Check for LON02
   [Documentation]    - LON02 Health Check Script Component- CIBR
   CIBR Services Check    ${LON02}

AAA Services Check for LON02
   [Documentation]    - LON02 Health Check Script Component- AAA
   AAA Services Check    ${LON02}

RSX Services Check for LON02
   [Documentation]    - LON02 Health Check Script Component- RSX
   RSX Services Check    ${LON02}

PROD-PRX Services Check for LON02
   [Documentation]    - LON02 Health Check Script Component- PROD-PRX
   PROD Services Check    ${LON02}

#WCS Services Check for LON02
#   [Documentation]    - LON02 Health Check Script Component- WCS
#   WCS Services Check    ${LON02}

VPNAT Services Check for LON02
   [Documentation]    - LON02 Health Check Script Component- VPNAT
   VPNNAT Services Check    ${LON02}


