*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot


*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for IAD
    [Documentation]    - IAD Health Check Script Component- DCR
    DCR Services Check    ${IAD}

ABR Services Check for IAD
    [Documentation]    - IAD Health Check Script Component- ABR
    ABR Services Check    ${IAD}

XEPA Services Check for IAD
    [Documentation]    - IAD Health Check Script Component- XEPA
    XEPA Services Check    ${IAD}

CIBR Services Check for IAD
   [Documentation]    - IAD Health Check Script Component- CIBR
   CIBR Services Check    ${IAD}

RSX Services Check for IAD
   [Documentation]    - IAD Health Check Script Component- RSX
   RSX Services Check    ${IAD}

#WCS Services Check for IAD
#   [Documentation]    - IAD Health Check Script Component- WCS
#   WCS Services Check    ${IAD}

COL Services Check for IAD
    [Documentation]    - IAD Health Check Script Component- COL
    COL Services Check    ${IAD}

AAA Services Check for IAD
   [Documentation]    - IAD Health Check Script Component- AAA
   AAA Services Check    ${IAD}

PROD-PRX Services Check for IAD
   [Documentation]    - IAD Health Check Script Component- PROD-PRX
   PROD Services Check    ${IAD}

VPNAT Services Check for IAD
   [Documentation]    - IAD Health Check Script Component- VPNAT
   VPNNAT Services Check    ${IAD}