*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot
*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for YMQ
    [Documentation]    - YMQ Health Check Script Component- DCR
    DCR Services Check    ${YMQ}

ABR Services Check for YMQ
    [Documentation]    - YMQ Health Check Script Component- ABR
    ABR Services Check    ${YMQ}

XEPA Services Check for YMQ
    [Documentation]    - YMQ Health Check Script Component- XEPA
    XEPA Services Check    ${YMQ}

COL Services Check for YMQ
    [Documentation]    - YMQ Health Check Script Component- COL
    COL Services Check    ${YMQ}

CIBR Services Check for YMQ
   [Documentation]    - YMQ Health Check Script Component- CIBR
   CIBR Services Check    ${YMQ}

AAA Services Check for YMQ
   [Documentation]    - YMQ Health Check Script Component- AAA
   AAA Services Check    ${YMQ}

RSX Services Check for YMQ
   [Documentation]    - YMQ Health Check Script Component- RSX
   RSX Services Check    ${YMQ}

PROD-PRX Services Check for YMQ
   [Documentation]    - YMQ Health Check Script Component- PROD-PRX
   PROD Services Check    ${YMQ}

#WCS Services Check for YMQ
#   [Documentation]    - YMQ Health Check Script Component- WCS
#   WCS Services Check    ${YMQ}
#
VPNAT Services Check for YMQ
   [Documentation]    - YMQ Health Check Script Component- VPNAT
   VPNNAT Services Check    ${YMQ}