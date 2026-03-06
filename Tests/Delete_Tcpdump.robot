*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
Delete Tcpdump on all ABR's
    [Documentation]    - Delete Tcpdump on all ABR's
    Delete Tcpdump on all ABR'S    ${ABR}