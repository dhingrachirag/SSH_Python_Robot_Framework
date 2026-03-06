*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot
Resource    ../Variables/HealthCheck_Variables.robot

*** Variables ***



*** Keywords ***


*** Test Cases ***
Check AAA singaore for SYD
    [Documentation]    - AAA Singapore Check
    AAA Services Check    ${singapore_AAA}