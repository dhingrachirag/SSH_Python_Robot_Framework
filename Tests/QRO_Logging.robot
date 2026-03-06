*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for QRO
    [Documentation]    - QRO Health Check Script Component- DCR
    DCR Services Check    ${QRO}

ABR Services Check for QRO
    [Documentation]    - QRO Health Check Script Component- ABR
    ABR Services Check    ${QRO}

XEPA Services Check for QRO
    [Documentation]    - QRO Health Check Script Component- XEPA
    XEPA Services Check    ${QRO}

COL Services Check for QRO
    [Documentation]    - QRO Health Check Script Component- COL
    COL Services Check    ${QRO}

CIBR Services Check for QRO
   [Documentation]    - QRO Health Check Script Component- CIBR
   CIBR Services Check    ${QRO}

AAA Services Check for QRO
   [Documentation]    - QRO Health Check Script Component- AAA
   AAA Services Check    ${QRO}

RSX Services Check for QRO
   [Documentation]    - QRO Health Check Script Component- RSX
   RSX Services Check    ${QRO}

PROD-PRX Services Check for QRO
   [Documentation]    - QRO Health Check Script Component- PROD-PRX
   PROD Services Check    ${QRO}

#WCS Services Check for QRO
#   [Documentation]    - QRO Health Check Script Component- WCS
#   WCS Services Check    ${QRO}

VPNAT Services Check for QRO
   [Documentation]    - QRO Health Check Script Component- VPNAT
   VPNNAT Services Check    ${QRO}
