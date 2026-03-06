*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
Kill Tcpdump on all ABR's
    [Documentation]    - Kill Tcpdump on all ABR's
    Kill Tcpdump on all ABR'S    ${ABR}