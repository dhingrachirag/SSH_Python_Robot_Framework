*** Settings ***
Resource    ../Resources/Common.robot
Resource    ../Resources/Health_Check.robot

*** Variables ***



*** Keywords ***



*** Test Cases ***
#DCR Services Check for IAD
#    [Documentation]    - IAD Health Check Script Component- DCR
#    DCR Services Check
#
#ABR Services Check for IAD
#    [Documentation]    - IAD Health Check Script Component- ABR
#    ABR Services Check
#
XEPA Services Check for IAD
    [Documentation]    - IAD Health Check Script Component- XEPA
    XEPA Services Check
#
#COL Services Check for IAD
#    [Documentation]    - IAD Health Check Script Component- COL
#    COL Services Check
#
#CIBR Services Check for IAD
#   [Documentation]    - IAD Health Check Script Component- CIBR
#   CIBR Services Check
#
#AAA Services Check for IAD
#   [Documentation]    - IAD Health Check Script Component- AAA
#   AAA Services Check
#
#RSX Services Check for IAD
#   [Documentation]    - IAD Health Check Script Component- RSX
#   RSX Services Check
#
#PROD-PRX Services Check for IAD
#   [Documentation]    - IAD Health Check Script Component- PROD-PRX
#   PROD Services Check
#
#WCS Services Check for IAD
#   [Documentation]    - IAD Health Check Script Component- WCS
#   WCS Services Check
#
#VPNAT Services Check for IAD
#   [Documentation]    - IAD Health Check Script Component- VPNAT
#   VPNNAT Services Check
##
# Establish Connection and Log In Single Server
#Login into Jump Server through routing
#    [Documentation]    - Login into multiple servers through routing
#    Establish Connection and Log In to AMB LAX directly
#
#Executing Health Checkup Script and Verification
#    [Documentation]    - Running Health Check up script
#    Establish Connection for Jump Server through Routing
#    Execute Health Check Script
#    Write Health Check Script in File and Verify Parameters
#
#Establish Healthcheck Checks
#    [Documentation]    - Healthcheck Checks on script
#    Establish Connection for Jump Server through TS-LAX-root for AMB-LAX
#    Execute Health Check Script
#    Write Health Check Script in File and Verify Parameters
#    Healthcheck All Keywords
#
#Check BGP Summary of All ABR
#   [Documentation]    Check BGP Summary of all ABRs
#   Check BGP Summary For All ABR's
#
#Establish Radius Command on AAA Simulator
#    [Documentation]    Run Radius Command
#    Establish Radius Command only
#    Executing Radius command and get IP of Client assigned by CORE
#
#Execute Healthcheck on All sites
#   [Documentation]    Check HealthCheck of all Sites and report if there is any error
#   Establish Connection for Jump Server through TS-LAX-root for AMB-LAX
#   HealthCheck of All sites
#
#Download pcap Files from Server
#    [Documentation]    Download Pcap files from server
#    Establish Connection and Log In to AMB LAX
#    Download Files from Server
