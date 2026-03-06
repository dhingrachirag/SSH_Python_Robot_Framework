*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
Collect Backups from AMB12 Machine
    [Documentation]    - Collect Backups from AMB12 Machine
    Collect Backups from AMB 12 Machine sreuser