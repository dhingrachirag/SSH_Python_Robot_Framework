*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
Collect Tcpdump on all ABR's
    [Documentation]    - Collect Tcpdump on all ABR's
    Collect Tcpdump on all ABR's    ${ABR}