*** Settings ***
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot


*** Variables ***



*** Keywords ***



*** Test Cases ***
#DCR Services Check for SYD
#    [Documentation]    - SYD Health Check Script Component- DCR
#    [Tags]    Parallel
#    DCR Services Check    ${SYD}

#ABR Services Check for SYD
#    [Documentation]    - SYD Health Check Script Component- ABR
##    [Tags]    Parallel
#    ABR Services Check    ${SYD}

XEPA Services Check for SYD
    [Documentation]    - SYD Health Check Script Component- XEPA
    [Tags]    Parallel
    XEPA Services Check    ${SYD}
#
#COL Services Check for SYD
#    [Documentation]    - SYD Health Check Script Component- COL
#    [Tags]    Parallel
#    COL Services Check    ${SYD}
#
#CIBR Services Check for SYD
#   [Documentation]    - SYD Health Check Script Component- CIBR
#   [Tags]    Parallel
#   CIBR Services Check    ${SYD}
#
#AAA Services Check for SYD
#   [Documentation]    - SYD Health Check Script Component- AAA
#   [Tags]    Parallel
#   AAA Services Check    ${SYD}
#
#RSX Services Check for SYD
#   [Documentation]    - SYD Health Check Script Component- RSX
#   [Tags]    Parallel
#   RSX Services Check    ${SYD}
#
#PROD-PRX Services Check for SYD
#   [Documentation]    - SYD Health Check Script Component- PROD-PRX
#   [Tags]    Parallel
#   PROD Services Check    ${SYD}
#
#VPNAT Services Check for SYD
#   [Documentation]    - SYD Health Check Script Component- VPNAT
#   [Tags]    Parallel
#   VPNNAT Services Check    ${SYD}


