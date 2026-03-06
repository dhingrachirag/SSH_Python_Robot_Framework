*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for FRA08
    [Documentation]    - FRA08 Health Check Script Component- DCR
    DCR Services Check    ${FRA08}

ABR Services Check for FRA08
    [Documentation]    - FRA08 Health Check Script Component- ABR
    ABR Services Check    ${FRA08}

XEPA Services Check for FRA08
    [Documentation]    - FRA08 Health Check Script Component- XEPA
    XEPA Services Check    ${FRA08}

COL Services Check for FRA08
    [Documentation]    - FRA08 Health Check Script Component- COL
    COL Services Check    ${FRA08}

CIBR Services Check for FRA08
   [Documentation]    - FRA08 Health Check Script Component- CIBR
   CIBR Services Check    ${FRA08}

AAA Services Check for FRA08
   [Documentation]    - FRA08 Health Check Script Component- AAA
   AAA Services Check    ${FRA08}

RSX Services Check for FRA08
   [Documentation]    - FRA08 Health Check Script Component- RSX
   RSX Services Check    ${FRA08}

PROD-PRX Services Check for FRA08
   [Documentation]    - FRA08 Health Check Script Component- PROD-PRX
   PROD Services Check    ${FRA08}

#WCS Services Check for FRA08
#   [Documentation]    - FRA08 Health Check Script Component- WCS
#   WCS Services Check    ${FRA08}

VPNAT Services Check for FRA08
   [Documentation]    - FRA08 Health Check Script Component- VPNAT
   VPNNAT Services Check    ${FRA08}


