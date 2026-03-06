*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
#DCR Services Check for DEN
#    [Documentation]    - DEN Health Check Script Component- DCR
#    [Tags]    Parallel
#    DCR Services Check    ${DEN}

ABR Services Check for DEN
    [Documentation]    - DEN Health Check Script Component- ABR
    [Tags]    Parallel
    ABR Services Check    ${DEN}

#XEPA Services Check for DEN
#    [Documentation]    - DEN Health Check Script Component- XEPA
#    [Tags]    Parallel
#    XEPA Services Check    ${DEN}
#
#COL Services Check for DEN
#    [Documentation]    - DEN Health Check Script Component- COL
#    [Tags]    Parallel
#    COL Services Check    ${DEN}
#
#CIBR Services Check for DEN
#   [Documentation]    - DEN Health Check Script Component- CIBR
#   [Tags]    Parallel
#   CIBR Services Check    ${DEN}
#
#AAA Services Check for DEN
#   [Documentation]    - DEN Health Check Script Component- AAA
#   [Tags]    Parallel
#   AAA Services Check    ${DEN}
#
#RSX Services Check for DEN
#   [Documentation]    - DEN Health Check Script Component- RSX
#   [Tags]    Parallel
#   RSX Services Check    ${DEN}
#
#PROD-PRX Services Check for DEN
#   [Documentation]    - DEN Health Check Script Component- PROD-PRX
#   [Tags]    Parallel
#   PROD Services Check    ${DEN}
#
#VPNAT Services Check for DEN
#   [Documentation]    - DEN Health Check Script Component- VPNAT
#   [Tags]    Parallel
#   VPNNAT Services Check    ${DEN}