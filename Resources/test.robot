*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections
Library    BuiltIn
Library    Process

*** Variables ***
${ssh_command}      ssh -o StrictHostKeyChecking=no
${connec_time_out}  Connection timed out
${No_route}         No route to host
${Destination_Host_Unreachable}  Destination Host Unreachable
${Something_is_wrong} Something is wrong
${64byts}           64 bytes

*** Keywords ***
Check ABR Baseline Version
    [Arguments]    ${ABR-IP}    ${username}    ${password}
    ${Baseline_Command}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} "cat /var/lib/portables/abrhost/.vars; cat /etc/hosts; systemctl list-units 'abr-*'; ip route show vrf a2b2a; ss | grep tcp"
    Log    ${Baseline_Command}

    Run Keyword And Continue On Failure    Check Baseline Version    ${Baseline_Command}
    Run Keyword And Continue On Failure    Check Connected XEPA      ${Baseline_Command}
    Run Keyword And Continue On Failure    Check Running Services    ${Baseline_Command}
    Run Keyword And Continue On Failure    Check Ping XEPA IP        ${Baseline_Command}    ${ABR-IP}    ${username}    ${password}

Check Baseline Version
    [Arguments]    ${Baseline_Command}
    ${baseline}=   Evaluate    'BASELINE' in '''${Baseline_Command}'''
    Log    ${baseline}
    ${version}=    Evaluate    'VERSION' in '''${Baseline_Command}'''
    Log    ${version}
    Should Not Contain    ${Baseline_Command}    ${connec_time_out}
    Should Not Contain    ${Baseline_Command}    ${No_route}

Check Connected XEPA
    [Arguments]    ${Baseline_Command}
    ${connectedXepa}=    Evaluate    re.search(r'control:http.*', '''${Baseline_Command}''').group(0).split(':')[0]
    Log    ${connectedXepa}
    Run Keyword If    '${connectedXepa}' and '${connectedXepa}'.endswith('.101')    Fail    - ABR is connected to CEMU
    ${regex_match}=    Evaluate    bool(re.match(r'.*\\.2[45]$', '${connectedXepa}'))
    Run Keyword If    '${connectedXepa}' and ${regex_match}    Log    - ABR is connected to Core

Check Running Services
    [Arguments]    ${Baseline_Command}
    ${running_services}=    Evaluate    '''${Baseline_Command}'''.count('running')
    ${exited_service}=      Evaluate    '''${Baseline_Command}'''.count('exited')
    Log    Running Services: ${running_services}, Exited Services: ${exited_service}
    Run Keyword If    ${running_services} == 11 and ${exited_service} == 2    Log    In all 13 ABR services are executing
    ... ELSE IF    ${running_services} == 10 and ${exited_service} == 2    Log    In all 12 ABR services are executing
    ... ELSE IF    ${running_services} < 10    Fail    Please check ABR services as less running services are running

Check Ping XEPA IP
    [Arguments]    ${Baseline_Command}    ${ABR-IP}    ${username}    ${password}
    ${grep_xepa_IP}=   Evaluate    re.search(r'xepa.control.*', '''${Baseline_Command}''').group(0).split()[0]
    Log    ${grep_xepa_IP}
    ${ping_XEPA_IP}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} "ping -c 2 -I control ${grep_xepa_IP}"
    Log    ${ping_XEPA_IP}
    Should Not Contain    ${ping_XEPA_IP}    ${Destination_Host_Unreachable}
    Should Not Contain    ${ping_XEPA_IP}    ${Something_is_wrong}
    Should Contain        ${ping_XEPA_IP}    ${64byts}


   ${connectedXepa}=    Execute command    echo "${Baseline_Command}" | grep control:http | awk '{print $6}' | cut -f 1 -d :
   log    ${connectedXepa}
    # Check if it ends with .101
   Run Keyword If    '${connectedXepa}' and '${connectedXepa}'.endswith('.101')    Fail    - ABR is connected to CEMU
    # Check if it matches .24 or .25 using regex
   ${regex_match}=    Evaluate Regex Match    .*\.2[45]$    ${connectedXepa}
   Run Keyword If    '${connectedXepa}' and ${regex_match}    Log    - ABR is connected to Core

   ${running_services}=    execute command    echo "${Baseline_Command}" | grep running | wc -l
   log    ${running_services}
   ${exited_service}=    execute command    echo "${Baseline_Command}" | grep exited | wc -l
   log    ${exited_service}
   IF    ${running_services} == 11 and ${exited_service} == 2
               log    In all 13 ABR services are executing
   ELSE IF    ${running_services} == 10 and ${exited_service} == 2
               log    In all 12 ABR services are executing
   ELSE IF     ${running_services} < 10
              fail    Please check ABR services as less running services are running
   END
   ${grep_xepa_IP}=   Execute command    echo "${Baseline_Command}" | grep xepa.control | cut -f 1 -d" "
   log    ${grep_xepa_IP}
   ${ping_XEPA_IP}=    Execute Command   ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} "ping -c 2 -I control ${grep_xepa_IP}"
   log    ${ping_XEPA_IP}
   should not contain    ${ping_XEPA_IP}    ${Destination_Host_Unreachable}
   should not contain    ${ping_XEPA_IP}    ${Something_is_wrong}
   should contain      ${ping_XEPA_IP}     ${64byts}


#    ${BGP_VRF}=    execute command    echo "${BGP_stats}" | grep 169.254 | cut -f 3 -d " "| grep ^10.
#    log    ${BGP_VRF}
#    ${BGP_VRF_CLEAN}=    Replace String    ${BGP_VRF}    \n    ${EMPTY}
#    IF    "${BGP_VRF_CLEAN}" == "${empty}"
#            log     No Private MNO Range configured in this ABR
#    ELSE
#           Log    Private range Configured in ABR
#    END


#    ${cbrvtep}=    execute command    echo "${BGP_stats2}" | awk -F',' 'NF == 6 {print $5}' | tail -n 1
#    log    ${cbrvtep}
#    ${BGP_stats}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'vtysh -c "sh ip bgp vrf undlay-vrf"'
#    log    ${BGP_stats}
#    ${cbrVTEPRoutePresent}=    execute command    echo "${BGP_stats}" | grep -o -E "$(echo ${cbrvtep} | sed 's/,/|/g')" | wc -l
#    log    ${cbrVTEPRoutePresent}


*** Test Cases ***
Test ABR Baseline Version
    Check ABR Baseline Version    192.168.1.1    admin    password
