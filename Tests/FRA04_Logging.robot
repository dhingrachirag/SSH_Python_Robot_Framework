*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for FRA04
    [Documentation]    - FRA04 Health Check Script Component- DCR
    DCR Services Check    ${FRA04}

ABR Services Check for FRA04
    [Documentation]    - FRA04 Health Check Script Component- ABR
    ABR Services Check    ${FRA04}

XEPA Services Check for FRA04
    [Documentation]    - FRA04 Health Check Script Component- XEPA
    XEPA Services Check    ${FRA04}

COL Services Check for FRA04
    [Documentation]    - FRA04 Health Check Script Component- COL
    COL Services Check    ${FRA04}

CIBR Services Check for FRA04
   [Documentation]    - FRA04 Health Check Script Component- CIBR
   CIBR Services Check    ${FRA04}

AAA Services Check for FRA04
   [Documentation]    - FRA04 Health Check Script Component- AAA
   AAA Services Check    ${FRA04}

RSX Services Check for FRA04
   [Documentation]    - FRA04 Health Check Script Component- RSX
   RSX Services Check    ${FRA04}

PROD-PRX Services Check for FRA04
   [Documentation]    - FRA04 Health Check Script Component- PROD-PRX
   PROD Services Check    ${FRA04}

CUST-RSX Services Check for FRA04
   [Documentation]    - FRA04 Health Check Script Component- CUST-RSX
   CUST-RSX Services Check    ${FRA04}

VPNAT Services Check for FRA04
   [Documentation]    - FRA04 Health Check Script Component- VPNAT
   VPNNAT Services Check    ${FRA04}


