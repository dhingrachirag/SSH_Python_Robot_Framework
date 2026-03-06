*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
CUST-RSX Services Check for FRA04
   [Documentation]    - FRA04 Health Check Script Component- CUST-RSX
   CUST-RSX Services Check    ${FRA04}

