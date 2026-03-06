*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot


*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for ATL
    [Documentation]    - ATL Health Check Script Component- DCR
    [Tags]    parallel
    DCR Services Check    ${ATL}

ABR Services Check for ATL
    [Documentation]    - ATL Health Check Script Component- ABR
    [Tags]    parallel
    ABR Services Check    ${ATL}

XEPA Services Check for ATL
    [Documentation]    - ATL Health Check Script Component- XEPA
    [Tags]    parallel
    XEPA Services Check    ${ATL}

CIBR Services Check for ATL
   [Documentation]    - ATL Health Check Script Component- CIBR
   [Tags]    parallel
   CIBR Services Check    ${ATL}

RSX Services Check for ATL
   [Documentation]    - ATL Health Check Script Component- RSX
   [Tags]    parallel
   RSX Services Check    ${ATL}

#WCS Services Check for ATL
#   [Documentation]    - ATL Health Check Script Component- WCS
#   WCS Services Check    ${ATL}

COL Services Check for ATL
    [Documentation]    - ATL Health Check Script Component- COL
    [Tags]    parallel
    COL Services Check    ${ATL}

AAA Services Check for ATL
   [Documentation]    - ATL Health Check Script Component- AAA
   [Tags]    parallel
   AAA Services Check    ${ATL}

PROD-PRX Services Check for ATL
   [Documentation]    - ATL Health Check Script Component- PROD-PRX
   [Tags]    parallel
   PROD Services Check    ${ATL}

VPNAT Services Check for ATL
   [Documentation]    - ATL Health Check Script Component- VPNAT
   [Tags]    parallel
   VPNNAT Services Check    ${ATL}