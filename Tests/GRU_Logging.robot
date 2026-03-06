*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
DCR Services Check for GRU
    [Documentation]    - GRU Health Check Script Component- DCR
    DCR Services Check    ${GRU}

ABR Services Check for GRU
    [Documentation]    - GRU Health Check Script Component- ABR
    ABR Services Check    ${GRU}

XEPA Services Check for GRU
    [Documentation]    - GRU Health Check Script Component- XEPA
    XEPA Services Check    ${GRU}

COL Services Check for GRU
    [Documentation]    - GRU Health Check Script Component- COL
    COL Services Check    ${GRU}

CIBR Services Check for GRU
   [Documentation]    - GRU Health Check Script Component- CIBR
   CIBR Services Check    ${GRU}

AAA Services Check for GRU
   [Documentation]    - GRU Health Check Script Component- AAA
   AAA Services Check    ${GRU}

RSX Services Check for GRU
   [Documentation]    - GRU Health Check Script Component- RSX
   RSX Services Check    ${GRU}

PROD-PRX Services Check for GRU
   [Documentation]    - GRU Health Check Script Component- PROD-PRX
   PROD Services Check    ${GRU}

WCS Services Check for GRU
   [Documentation]    - GRU Health Check Script Component- WCS
   WCS Services Check    ${GRU}
#
VPNAT Services Check for GRU
   [Documentation]    - GRU Health Check Script Component- VPNAT
   VPNNAT Services Check    ${GRU}


