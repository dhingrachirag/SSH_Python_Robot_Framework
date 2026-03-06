*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for MAD
    [Documentation]    - MAD Health Check Script Component- DCR
    DCR Services Check    ${MAD}

ABR Services Check for MAD
    [Documentation]    - MAD Health Check Script Component- ABR
    ABR Services Check    ${MAD}

XEPA Services Check for MAD
    [Documentation]    - MAD Health Check Script Component- XEPA
    XEPA Services Check    ${MAD}

COL Services Check for MAD
    [Documentation]    - MAD Health Check Script Component- COL
    COL Services Check    ${MAD}

CIBR Services Check for MAD
   [Documentation]    - MAD Health Check Script Component- CIBR
   CIBR Services Check    ${MAD}

AAA Services Check for MAD
   [Documentation]    - MAD Health Check Script Component- AAA
   AAA Services Check    ${MAD}

RSX Services Check for MAD
   [Documentation]    - MAD Health Check Script Component- RSX
   RSX Services Check    ${MAD}

PROD-PRX Services Check for MAD
   [Documentation]    - MAD Health Check Script Component- PROD-PRX
   PROD Services Check    ${MAD}

WCS Services Check for MAD
   [Documentation]    - MAD Health Check Script Component- WCS
   WCS Services Check    ${MAD}

VPNAT Services Check for MAD
   [Documentation]    - MAD Health Check Script Component- VPNAT
   VPNNAT Services Check    ${MAD}