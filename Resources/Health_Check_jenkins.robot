*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
Library    String
Library    Collections
Resource   ../Variables/globalvariables.robot
Resource    ../Variables/HealthCheck_Variables.robot
Library    ../CustomLibs/csv2.py
Library     CryptoLibrary    variable_decryption=False
Resource   ../Variables/Authentication_variables.robot
Resource    ../Resources/Common.robot

*** Variables ***

*** Keywords ***

Check for authentication of hosts before running tests
    [Arguments]    ${ip}
    ${host}=    execute command    ssh-keygen -f "//root//.ssh//known_hosts" -R ${ip}
    log    ${host}
    IF    $found in $host
         log    Host already added in know hosts
    ELSE
         log    ${host} added in known hosts
    END

ABR Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["ABR"]}
    Log  ${properties}
    @{Failed_ABRs}=    Create List
    @{Passed_ABRs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All ABR Services    ${sub dict}[ABR-IP]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    ABR services report is not fine. Please Check 'Check All ABR Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_ABRs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_ABRs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed ABRS: ${Passed_ABRs}    Passed ABRS Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All ABR's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed ABR's    Log Many    Failed ABRS: ${Failed_ABRs}    Failed ABRS Count: ${fail}    Please Check ABR Services in logs for ${Failed_ABRs}

    END

Check All ABR Services
    [Arguments]    ${ABR-IP}    ${username}    ${password1}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
    Establish Connection and Log In to AMB LAX directly
    Run Keyword and Continue On Failure    Check ABR enhanced checks    ${ABR-IP}    ${username}    ${password}
    Run Keyword and Continue On Failure    Check BGP connectivity with neighbours    ${ABR-IP}    ${username}    ${password}
    Run Keyword and Continue On Failure    Check BGP Stats    ${ABR-IP}    ${username}    ${password}
    Run Keyword and Continue On Failure    Check BGP connectivity ABR    ${ABR-IP}    ${username}    ${password}
    Run Keyword and Continue On Failure    Check undlay-vrf ping-ability    ${ABR-IP}    ${username}    ${password}
    Run Keyword and Continue On Failure    Check RR Coneectivity with ABR    ${ABR-IP}    ${username}    ${password}
    close all connections

Check ABR enhanced checks
   [Arguments]    ${ABR-IP}    ${username}    ${password}
   ${Baseline_Command}=    Execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'cat /var/lib/portables/abrhost/.vars; cat /etc/hosts; systemctl list-units "abr-*"; ip route show vrf a2b2a; ss | grep tcp'
   log    ${Baseline_Command}
    Run Keyword And Continue On Failure    Check Baseline Version    ${Baseline_Command}
    Run Keyword And Continue On Failure    Check Connected XEPA      ${Baseline_Command}
    Run Keyword And Continue On Failure    Check Running Services    ${Baseline_Command}
    Run Keyword And Continue On Failure    Check Ping XEPA IP        ${Baseline_Command}    ${ABR-IP}    ${username}    ${password}
    Run Keyword And Continue On Failure    Check vrf default route   ${Baseline_Command}
    Run Keyword And Continue On Failure    Check CIBR's Connectivity    ${Baseline_Command}

Evaluate Regex Match
    [Arguments]    ${pattern}    ${value}
    ${match}=    Evaluate    re.match(r"${pattern}", r"${value}") is not None
    [Return]    ${match}

Check Baseline Version
    [Arguments]    ${Baseline_Command}
    ${baseline}=   Execute command    echo "${Baseline_Command}" | grep BASELINE
    log    ${baseline}
    ${version}=   Execute command    echo "${Baseline_Command}" | grep VERSION
    log    ${version}
    Should Not Contain    ${Baseline_Command}    ${connec_time_out}
    Should Not Contain    ${Baseline_Command}    ${No_route}

Check Connected XEPA
    [Arguments]    ${Baseline_Command}
    ${connectedXepa}=    Execute command    echo "${Baseline_Command}" | grep control:http | awk '{print $6}' | cut -f 1 -d : | sort -u
    log    ${connectedXepa}
    Run Keyword If    '${connectedXepa}' and '${connectedXepa}'.endswith('.101')    Fail    ABR is connected to CEMU
    ${regex_match}=    Evaluate Regex Match    .*\.2[45]$    ${connectedXepa}
    Run Keyword If    '${connectedXepa}' and ${regex_match}    Log    ABR is connected to Core

Check Running Services
    [Arguments]    ${Baseline_Command}
    ${running_services}=    Evaluate    '''${Baseline_Command}'''.count('running')
    ${exited_service}=      Evaluate    '''${Baseline_Command}'''.count('exited')
    Log    Running Services: ${running_services}, Exited Services: ${exited_service}
    Run Keyword If    '${running_services}'=='*"0 loaded units listed"*'
    ...    Fail    All services of ABR are down

    Run Keyword If    ${running_services}==${expected_running_services} and ${exited_service}==${expected_exited_services}
    ...    Log    In all ${expected_running_services} ABR services are executing. Running count is ${running_services} and Exited count is ${exited_service}

    Run Keyword If    ${running_services}<${expected_running_services}
    ...    Fail    Please check ABR services as less running services are running

    Run Keyword If    ${running_services}>=${expected_running_services} and (${running_services}!=${expected_running_services} or ${exited_service}!=${expected_exited_services})
    ...    Fail    Something wrong with ABR Services, Please check

Check Ping XEPA IP
    [Arguments]    ${Baseline_Command}    ${ABR-IP}    ${username}    ${password}
    ${grep_xepa_IP}=   Evaluate    re.search(r'xepa.control.*', '''${Baseline_Command}''').group(0).split()[0]
    Log    ${grep_xepa_IP}
    ${ping_XEPA_IP}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} "ping -c 2 -I control ${grep_xepa_IP}"
    Log    ${ping_XEPA_IP}
    Should Not Contain    ${ping_XEPA_IP}    ${Destination_Host_Unreachable}
    Should Not Contain    ${ping_XEPA_IP}    ${Something_is_wrong}
    Should Contain        ${ping_XEPA_IP}    ${64byts}

Check vrf default route
   [Arguments]    ${Baseline_Command}
   ${check_verf}    Execute command    echo "${Baseline_Command}" | grep ^default
   log    ${check_verf}
   should contain    ${check_verf}    ${default}    msg=Default route is not found for brkout interface, please check vrf a2b2a

Check CIBR's Connectivity
   [Arguments]    ${Baseline_Command}
   ${CIBR_Connect}=    execute command    echo "${Baseline_Command}" 'ss | grep control | grep ESTAB'
   log    ${CIBR_Connect}
   ${cibr_count}=   Execute command    echo "${CIBR_Connect}" | egrep ".20:77|.21:77|.36:77" | wc -l
   log    ${cibr_count}
   ${cibr1_count}=   Execute command    echo "${CIBR_Connect}" | egrep ".20:77" | wc -l
   log    ${cibr1_count}
   ${cibr2_count}=   Execute command    echo "${CIBR_Connect}" | egrep ".21:77" | wc -l
   log    ${cibr2_count}
   ${cibr_cemu_count}=   Execute command    echo "${CIBR_Connect}" | egrep ".36:77" | wc -l
   log    ${cibr_cemu_count}
   IF   ${cibr_count} == 2
               log    TCP:Both CIBR connections are up
   ELSE IF    ${cibr_count} < 2
               Run Keyword If    ${cibr1_count} < 1    fail    TCP: CIBR1 connection is down
               Run Keyword If    ${cibr2_count} < 1    fail    TCP: CIBR2 connection is down
   ELSE
             Fail    log    TCP:Issue with CIBR connectivity
   END

Check BGP connectivity with neighbours
   [Arguments]    ${ABR-IP}    ${username}    ${password}
   ${BGP_Connect}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'ss | grep tcp | grep bgp | grep ESTAB'
   log    ${BGP_connect}
   ${totalCount}=    execute command     echo "${BGP_connect}" | grep ESTAB | wc -l
   log    ${totalCount}
   IF    ${totalCount} != 8
         ${undlay}=   execute command    echo "${BGP_connect}" | grep undlay | wc -l
         log    ${undlay}
         run keyword and continue on failure    Run keyword if    ${undlay} <2    fail    One or both Undlay TCP connections are down
         ${RSX}=    execute command    echo "${BGP_connect}" | egrep ".5:|.6:" | wc -l
         log    ${RSX}
         run keyword and continue on failure    Run keyword if    ${RSX} <2    fail    RSX:One or both connections are down
         ${PGW}=    execute command    echo "${BGP_connect}" | egrep ".13:|.14:" | wc -l
         log    ${PGW}
         run keyword and continue on failure    Run keyword if    ${PGW} <2    fail    PGW:One or both connections are down
         ${CGNAT}=    execute command    echo "${BGP_connect}" | egrep ".23:|.24:" | wc -l
         log    ${CGNAT}
         run keyword and continue on failure    Run keyword if    ${CGNAT} <2    fail    CGNAT:One or both connections are down
   ELSE
        log    All sockets for 2 Undlay, 2 RSXs, 2 PGWs and 2 CGNATs are connected
   END

Check Undlay-vrf statistics
    [Arguments]    ${ABR-IP}    ${username}    ${password}
    ${undlay_stats}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'vtysh -c "sh ip bgp vrf undlay-vrf" | grep Displayed'
    log    ${undlay_stats}
    ${baseline_stats}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'grep BASELINE /var/lib/portables/abr/.vars | cut -f 2 -d d'
    log    ${baseline_stats}

Check BGP Stats
    [Arguments]    ${ABR-IP}    ${username}    ${password}
    ${Baseline_Command_BGP}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'cat /etc/opt/abr/naname.conf; cat /etc/hosts'
    log    ${Baseline_Command_BGP}
    ${BGP_stats}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'vtysh -c "sh ip bgp" | grep 169.254'
    log    ${BGP_stats}
    run keyword and continue on failure    Check CBR Connection    ${Baseline_Command_BGP}    ${ABR-IP}    ${username}    ${password}
    run keyword and continue on failure    Check Private range MNO of DE site     ${BGP_stats}

Check CBR Connection
    [Arguments]    ${Baseline_Command_BGP}    ${ABR-IP}    ${username}    ${password}
    ${cbrvtep}=    execute command    echo "${Baseline_Command_BGP}" | awk -F',' 'NF == 6 {print $5}' | tail -n 1
    log    ${cbrvtep}
    ${BGP_stats}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'vtysh -c "sh ip bgp vrf undlay-vrf"'
    log    ${BGP_stats}
    ${cbrVTEPRoutePresent}=    execute command    echo "${BGP_stats}" | grep -o -E "$(echo ${cbrvtep} | sed 's/,/|/g')" | wc -l
    log    ${cbrVTEPRoutePresent}
    Run Keyword If    ${cbrVTEPRoutePresent} < 1    Fail    One or more of CBRs are disconnected
    ...    ELSE    Log    Connected cbrVTEPRoutePresent=${cbrVTEPRoutePresent}

Check Private range MNO of DE site
    [Arguments]    ${BGP_stats}
    ${BGP_VRF}=    execute command    echo "${BGP_stats}" | awk '$1 == "*>"{print $2}' | grep ^10.
    log    ${BGP_VRF}
    ${BGP_VRF_CLEAN}=    Replace String    ${BGP_VRF}    \n    ${EMPTY}
    IF    "${BGP_VRF_CLEAN}" == "${empty}"
            log     No Private MNO Range configured in this ABR
    ELSE
           Log    Private range Configured in ABR
    END

Check BGP connectivity ABR
    [Arguments]    ${ABR-IP}    ${username}    ${password}
    ${BGP_stats}=    execute command     ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} vtysh -c \\"show ip bgp sum\\" | awk 'NR>2 {print $10}' | awk 'NR>1 {gsub(/^[[:space:]]+|State\/PfxRcd$/,""); print}' | grep [a-z,A-Z] | wc -l
    log    ${BGP_stats}
    IF    "${BGP_stats}" == "0"
         log    BGP Connectivity is Fine.
    ELSE
        Fail    log    BGP Connectivity is not fine
    END

Check undlay-vrf ping-ability
    [Arguments]    ${ABR-IP}    ${username}    ${password}
    ${undlay_ping33}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'ping -c 2 -I undlay-vrf ${undlay-vrf33}'
    log    ${undlay_ping33}
    ${undlay_ping34}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'ping -c 2 -I undlay-vrf ${undlay-vrf34}'
    log    ${undlay_ping34}
    should not contain    ${undlay_ping33}    ${Destination_Host_Unreachable}
    should not contain    ${undlay_ping33}    ${Something_is_wrong}
    should contain      ${undlay_ping33}     ${64byts}
    should not contain    ${undlay_ping34}    ${Destination_Host_Unreachable}
    should not contain    ${undlay_ping34}    ${Something_is_wrong}
    should contain      ${undlay_ping34}     ${64byts}

Check RR Coneectivity with ABR
    [Arguments]    ${ABR-IP}    ${username}    ${password}
    ${RR_Connect}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} 'ss | grep 194.35.38'
    log    ${RR_Connect}
    ${totalCount}=    execute command     echo "${RR_Connect}" | grep ESTAB | wc -l
    log    ${totalCount}
   IF   ${totalCount} == 2
               log    RR to ABR Connectivity is up
   ELSE IF    ${totalCount} < 2
               Fail    log    One or both RR connectivity with ABR are down
   ELSE
             Fail    log    Connectivity Issue with RR
   END

Check AAA Radius Version
    [Arguments]    ${ip}    ${username}    ${password}
    ${radius_version}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} /usr/local/sbin/radiusd -v | grep Version | awk '{ print $4 }' | cut -f 3 -d / | cut -f 1
    log    ${radius_version}
    IF    "${radius_version}" == "${empty}"
          Fail    log    Radius version is not found
    ELSE
         log    Radius server version is ${radius_version}
    END


Check whether AAA Radius Server is running or not
    [Arguments]    ${ip}    ${username}    ${password}
    ${radius_server}=    Execute Command   ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /usr/local/var/radiusd.pid
    log    ${radius_server}
    IF    "${radius_server}" == "${empty}"
          Fail    log    Radius server is not running
    ELSE
         log    Radius server is running
    END

Check whether Apex Server is running or Not
    [Arguments]    ${ip}    ${username}    ${password}
    ${apex_server}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /usr/local/var/apex/pid
    log    ${apex_server}
    IF    "${apex_server}" == "${empty}"
          Fail    log    Apex server is not running
    ELSE
         log    Apex server is running
    END

Check which of the AAA is Master
    [Arguments]    ${ip}    ${username}    ${password}
    ${AAA_master}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep eth2 /usr/local/var/radiusd/radacct/apex.log* | tail -1 | cut -f2
    log    ${AAA_master}
    IF    "${AAA_master}" == "${empty}"
          log    Logs have not been flipped
    ELSE
         log    Server is running as ${AAA_master}
    END

Check if pointed to Core or Emulator and if pingable
    [Arguments]    ${ip}    ${username}    ${password}    ${simulator_ip}
    ${ip_returned}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep ^orch_server /etc/apex.d/tpyd.sysconf | cut -c 15-30
    log    ${ip_returned}
    IF    "${ip_returned}" == "${IP_of_Core}"
          log    Server is pointing to Core
          ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${IP_of_Core}"
          should not contain    ${resp}    ${Destination_Host_Unreachable}
          should not contain    ${resp}    ${Something_is_wrong}
          should contain      ${resp}     ${64byts}
    ELSE IF    "${ip_returned}" == "${IP_of_PortableNW_zz0}"
          log    Server is pointing to Portable Network
          ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${IP_of_PortableNW_zz0}"
          should not contain    ${resp}    ${Destination_Host_Unreachable}
          should not contain    ${resp}    ${Something_is_wrong}
          should contain      ${resp}     ${64byts}
    ELSE IF    "${ip_returned}" == "${IP_of_Core_Singapore}"
          log    Server is pointing to core of singapore
          ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${IP_of_Core_Singapore}"
          should not contain    ${resp}    ${Destination_Host_Unreachable}
          should not contain    ${resp}    ${Something_is_wrong}
          should contain      ${resp}     ${64byts}
    ELSE IF    "${ip_returned}" == "${simulator_ip}"
         log    Server is pointing to Emulator deployed on AAA Sim
         ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${simulator_ip}"
         should not contain    ${resp}    ${Destination_Host_Unreachable}
         should not contain    ${resp}    ${Something_is_wrong}
         should contain      ${resp}     ${64byts}
    ELSE
        log    Something is wrong, instead of Core or Emulator the response returned is ${ip_returned}
    END


Check Gateway IP
     [Arguments]    ${ip}    ${username}    ${password}
     ${gatewayip}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep 172.30.255 /etc/sysconfig/network-scripts/route-eth1 | awk '{ print $3 }'
     log    ${gatewayip}
     ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${gatewayip}"
     should not contain    ${resp}    ${Destination_Host_Unreachable}
     should not contain    ${resp}    ${Something_is_wrong}
     should contain      ${resp}     ${64byts}

Check All AAA Services
    [Arguments]    ${ip}    ${username}    ${password1}    ${simulator_ip}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
#    Establish Connection and Log In Singapore Server
    Establish Connection and Log In to AMB LAX directly
    run keyword and continue on failure    Check AAA Radius Version    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check whether AAA Radius Server is running or not    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check whether Apex Server is running or Not    ${ip}    ${username}    ${password}
#    run keyword and continue on failure    Check which of the AAA is Master    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check if pointed to Core or Emulator and if pingable    ${ip}    ${username}    ${password}    ${simulator_ip}
    run keyword and continue on failure    Check Gateway IP    ${ip}    ${username}    ${password}
    close all connections

AAA Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["AAA"]}
    Log  ${properties}
    @{Failed_AAAs}=    Create List
    @{Passed_AAAs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All AAA Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]    ${sub dict}[simulator_ip]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    AAA services report is not fine. Please Check 'Check All AAA Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_AAAs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_AAAs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed AAAs: ${Passed_AAAs}    Passed AAAs Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All AAA's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed AAA's    Log Many    Failed AAAs: ${Failed_AAAs}    Failed AAAs Count: ${fail}    Please Check AAA Services in logs for ${Failed_AAAs}

    END

Check XEPA Version
    [Arguments]    ${ip}    ${username}    ${password}
    ${XEPA_version}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep pre xepa.log | tail -1 | cut -f 2 -d "(" | cut -f 1 -d ")"
    log    ${XEPA_version}
    IF    "${XEPA_version}" == "${empty}"
          Fail    log    XEPA version is not found
    ELSE
         log    XEPA Version is ${XEPA_version}
    END



Check XEPA if running as Master or Backup
    [Arguments]    ${ip}    ${username}    ${password}
    ${XEPA_master}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} tail -10 /usr/local/var/log/xepa.log
    log    ${XEPA_master}
    ${totalCount}    execute command    echo "${XEPA_master}" | grep keepalive | wc -l
    log    ${totalCount}
    IF    ${totalCount} > 1
          log    xepa is Master
    ELSE
          log    xepa is slave
    END

Check Core's reachablility from XEPA
    [Arguments]    ${ip}    ${username}    ${password}
    ${XEPA_master_1}=    execute command     ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "cat /etc/xepa.d/tpyd.sysconf | grep -v '#' | grep OrchSrvr.addr"
    ${XEPA_master}=    should match regexp     ${XEPA_master_1}     ${IPregex}
    log    ${XEPA_master}
    IF    "${XEPA_master}" == "${IP_of_Core}"
          log    Server is pointing to Core
          ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${IP_of_Core}"
          should not contain    ${resp}    ${Destination_Host_Unreachable}
          should not contain    ${resp}    ${Something_is_wrong}
          should contain      ${resp}     ${64byts}
    ELSE IF    "${XEPA_master}" == "${IP_of_PortableNW_zz0}"
          log    Server is pointing to Portable Network
          ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${IP_of_PortableNW_zz0}"
          should not contain    ${resp}    ${Destination_Host_Unreachable}
          should not contain    ${resp}    ${Something_is_wrong}
          should contain      ${resp}     ${64byts}
    ELSE IF    "${XEPA_master}" == "${IP_of_staging_Core}"
          log    Server is pointing to Portable Network
          ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${IP_of_staging_Core}"
          should not contain    ${resp}    ${Destination_Host_Unreachable}
          should not contain    ${resp}    ${Something_is_wrong}
          should contain      ${resp}     ${64byts}
    ELSE IF    "${XEPA_master}" == "${IP_of_Core_Singapore}"
          log    Server is pointing to core of singapore
          ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping -c 2 -I eth1 ${IP_of_Core_Singapore}"
          should not contain    ${resp}    ${Destination_Host_Unreachable}
          should not contain    ${resp}    ${Something_is_wrong}
          should contain      ${resp}     ${64byts}
    ELSE
          Fail    log    Something is wrong, instead of Core or Emulator the response returned is ${XEPA_master}
    END

Check whether pointing to Core
    [Arguments]    ${ip}    ${username}    ${password}
    ${XEPA_master}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep ^OrchSrvr.addr /etc/xepa.d/tpyd.sysconf | cut -f3 -d " "
    log    ${XEPA_master}
    IF    "${XEPA_master}" == "${empty}"
          Fail    log     Core IP is missing from tpyd.conf
    ELSE
        log    Core IP is there in tpyd.conf
    END


Check Gateway Ip from XEPA
   [Arguments]    ${ip}    ${username}    ${password}
   ${XEPA_gateway}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep 172.30.255 /etc/sysconfig/network-scripts/route-eth1 | awk '{ print $3 }'
   log    ${XEPA_gateway}
   ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} ping -c 2 -I eth1 "${XEPA_gateway}"
   log    ${resp}
   should not contain    ${resp}    ${Destination_Host_Unreachable}
   should not contain    ${resp}    ${Something_is_wrong}
   should contain      ${resp}     ${64byts}

Check TCP connectivity to Core from XEPA
   [Arguments]    ${ip}    ${username}    ${password}
   ${XEPA_tcp}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} netstat -a | grep http
   log    ${XEPA_tcp}
   ${totalCount}    execute command    echo "${XEPA_tcp}" | grep 172.30.255 | grep ESTABLISHED | wc -l
   log    ${totalCount}
   IF    ${totalCount} < 1
          Fail    log    TCP:Connection to Core/CEMU is down
   ELSE
          log    TCP:Connection to Core/CEMU is established
   END

Check TCP connectivity to ABR from XEPA
   [Arguments]    ${ip}    ${username}    ${password}
   ${XEPA_tcp}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} netstat -a | grep http
   log    ${XEPA_tcp}
   ${totalCount}    execute command   echo "${XEPA_tcp}" | grep ESTABLISHED | awk '{ print $5 }' | grep -v 172.30.255.2 | wc -l
   log    ${totalCount}
   IF    ${totalCount} < 1
          Fail    log    TCP:Connection to ABRs is down
   ELSE
          log    TCP:Total ABRs with established status are ${totalCount}
   END

Check Nanames from XEPA and connectivity with each of the ABRs
   [Arguments]    ${ip}    ${username}    ${password}    ${ABR-IP}
   ${XEPA_Nanames}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} grep naname /etc/hosts | awk '{ print $3 }' | cut -d'.' -f2
   log    ${XEPA_Nanames}
   ${XEPA_namesoutput}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} grep naname /etc/hosts | awk '{ print $3 }' | awk -F'[ .]' '{ print $1"."$2 }'
   log    ${XEPA_namesoutput}
   ${XEPA_keepalive}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep keepalive xepa.log | grep "${XEPA_namesoutput}" | tail -1 | awk '{ print $3 }'
   log    ${XEPA_keepalive}
   sleep    10s
   ${XEPA_keepalive1}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep keepalive xepa.log | grep "${XEPA_namesoutput}" | tail -1 | awk '{ print $3 }'
   log    ${XEPA_keepalive1}
   IF    "${XEPA_keepalive}" < "${XEPA_keepalive1}"
          log    Xepa is connected to "${XEPA_namesoutput}"
   ELSE
          Fail    log    Xepa connectivity is lost with" "${XEPA_namesoutput}"
   END

Check All XEPA Services
    [Arguments]    ${ip}    ${username}    ${password1}    ${ABR-IP}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
    Establish Connection and Log In to AMB LAX directly
    ${XEPA_master}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} tail -10 /usr/local/var/log/xepa.log
    log    ${XEPA_master}
    ${totalCount}    execute command    echo "${XEPA_master}" | grep keepalive | wc -l
    log    ${totalCount}
    IF    ${totalCount} > 1
          log    xepa is Master
          #    run keyword and continue on failure    Check XEPA Version    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check XEPA if running as Master or Backup    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check Core's reachablility from XEPA    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check whether pointing to Core   ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check Gateway Ip from XEPA    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check TCP connectivity to Core from XEPA    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check TCP connectivity to ABR from XEPA   ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check Nanames from XEPA and connectivity with each of the ABRs    ${ip}    ${username}    ${password}    ${ABR-IP}
    ELSE
          log    xepa is slave
         #   run keyword and continue on failure    Check XEPA Version    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check XEPA if running as Master or Backup    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check Core's reachablility from XEPA    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check whether pointing to Core   ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check Gateway Ip from XEPA    ${ip}    ${username}    ${password}
         run keyword and ignore error           Check TCP connectivity to Core from XEPA    ${ip}    ${username}    ${password}
         run keyword and ignore error           Check TCP connectivity to ABR from XEPA   ${ip}    ${username}    ${password}
         run keyword and ignore error           Check Nanames from XEPA and connectivity with each of the ABRs    ${ip}    ${username}    ${password}    ${ABR-IP}
    END
    close all connections


XEPA Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["XEPA"]}
    Log  ${properties}
    ${properties1}=  Set Variable  ${parsed["DE Site"]["ABR"]}
    Log  ${properties1}
    @{Failed_XEPAs}=    Create List
    @{Passed_XEPAs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key1}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key1}
         Log  ${sub dict}
         FOR    ${key}    IN    @{properties1}
                 ${sub dict1}=    Get From Dictionary    ${properties1}    ${key}
                 Log  ${sub dict1}
                 ${status}=    run keyword and return status    Check All XEPA Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]    ${sub dict1}[ABR-IP]
                 log    ${status}
         END
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    XEPA services report is not fine. Please Check 'Check All XEPA Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
                ${fail}=    Evaluate    ${fail} + 1
                log    ${fail}
                append to list    ${Failed_XEPAs}    ${key1}
         ELSE IF    ${passed}
                ${pass}=    Evaluate    ${pass} + 1
                log    ${pass}
                append to list    ${Passed_XEPAs}    ${key1}
                Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed XEPA: ${Passed_XEPAs}    Passed XEPAs Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All XEPA's are passing.There is no Failure
   ELSE
           run keyword and continue on failure    Fail    Failed XEPA's    Log Many    Failed XEPAs: ${Failed_XEPAs}    Failed XEPAs Count: ${fail}    Please Check XEPA Services in logs for ${Failed_XEPAs}

   END

Check RSX Number of Global Ip Addresses
   [Arguments]    ${ip}    ${username}    ${password}
   ${RSX_IP}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} 'ip addr | grep global | wc -l'
   log    ${RSX_IP}
   should not contain    ${RSX_IP}    ${connec_time_out}
   IF    $connec_time_out in $RSX_IP
         Fail    log    Server does not exist
   ELSE IF    "${RSX_IP}" == "${empty}"
          Fail    log    Something wrong, please check RSX connectivity
   ELSE IF    ${RSX_IP} < 10
         Fail    log    Something wrong, as the ip addr spwaned are - ${RSX_IP}, which is less than expected count of 8
   ELSE IF    ${RSX_IP} > 10
         Fail    log    Something wrong, as the ip addr spwaned are - ${RSX_IP}, which is more than expected count of 8
   ELSE
        log     ip addr loops good as all IPs including loopback are instantiated.
   END

Check RSX answerx Services
   [Arguments]    ${ip}    ${username}    ${password}
   ${RSX_IP}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} 'systemctl status answerx.service | egrep "Loaded|Active|Process|PID"'
   log    ${RSX_IP}
   should contain    ${RSX_IP}    ${active}    msg=Something wrong please check the answerx service    values=False
   should contain    ${RSX_IP}    ${success}   msg=Something wrong please check the answerx service   values=False

Find DNS IP to check Internet Connectivity RSX
   [Arguments]    ${ip}    ${username}    ${password}
   ${RSX_IP}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /etc/network/interfaces.d/lo.cfg | grep address | head -1 | awk '{print $2}' | cut -d'/' -f1
   log    ${RSX_IP}
   ${resp}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping 1.1.1.1 -I ${RSX_IP} -c 2"
   should not contain    ${resp}    ${Destination_Host_Unreachable}    msg=Internet not working    values=False
   should not contain    ${resp}    ${Something_is_wrong}    msg=Internet not working    values=False
   should contain      ${resp}     ${64byts}    msg=Internet not working    values=False

Check TCP Statistics RSX
    [Arguments]    ${ip}    ${username}    ${password}
    ${RSX_IP}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} 'ss | grep tcp | grep bgp | grep ESTAB'
    log    ${RSX_IP}
    IF    $connec_time_out in $RSX_IP
         Fail    log    Connection Timed Out. Instance does not exist
    ELSE
        ${totalCount}    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} 'ss | grep tcp | grep bgp | grep ESTAB | wc -l'
        log    ${totalCount}
        IF    ${totalCount} != 4
              Fail    log    One or more BGP sockets are disconnected from Peers
        ELSE
              log    All ABR and BR sockets are connected
        END
    END

Check All ABR sockets are connected for TCP RSX
    [Arguments]    ${ip}    ${username}    ${password}
    ${ABR}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} 'ss | grep tcp | grep bgp | grep ESTAB | egrep ".3:|.4:" | wc -l'
    log    ${ABR}
    IF    ${ABR} < 2
          Fail    log    One or both BGP connections to ABRs are down
    ELSE
         log    Connections to ABRs are Up
    END

Check All BR sockets are connected for TCP RSX
    [Arguments]    ${ip}    ${username}    ${password}
    ${BR}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} 'ss | grep tcp | grep bgp | grep ESTAB | egrep ".1:|.2:" | wc -l'
    log    ${BR}
    IF    ${BR} < 2
          Fail    log    One or both BGP connections to BRs are down
    ELSE
         log    Connections to BRs are Up
    END

Check BGP Statistics for RSX
    [Arguments]    ${ip}    ${username}    ${password}
    ${BGP_RSX}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "show bgp sum"' | egrep '169.254|172.31' | wc -l
    log    ${BGP_RSX}
    ${resp}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "show bgp sum"' | egrep '169.254|172.31' | awk '{ print $1": "$10 }'
    log    ${resp}
    IF    ${BGP_RSX} != 4
          ${ABR}    execute command    echo "${resp}" | egrep ".3:|.4:" | wc - l
          log    ${ABR}
          ${BR}    execute command    echo "${resp}" | egrep ".1:|.2:" | wc -l
          log    ${BR}
          IF    ${ABR} < 2
                  Fail    log    One or both BGP connections to ABRs are down
          ELSE
                  log    Connections to ABRs are Up
          END
          IF    ${BR} < 2
                  Fail    log    One or both BGP connections to BRs are down
          ELSE
                  log    Connections to BRs are Up
          END
    ELSE
         log    All ABRs and BRs are connected
    END

Check IP BGP Statistics for RSX
    [Arguments]    ${ip}    ${username}    ${password}
    ${BGP_RSX}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "sh ip bgp"' | grep Displayed
    log    ${BGP_RSX}
    ${BGP_Routes}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "sh ip bgp"' | grep Displayed | awk '{ print $2 }'
    log    Number of Routes are ${BGP_Routes}
    ${BGP_Paths}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "sh ip bgp"' | grep Displayed | awk '{ print $5 }'
    log    Total number of Paths are ${BGP_Paths}


Check Public DNS for RSX
   [Arguments]    ${ip}    ${username}    ${password}
   ${BGP_RSX}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "sh ip bgp"' | grep 170.199 | wc -l
   log    ${BGP_RSX}
   ${BGP_RSX1}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "sh ip bgp"' | grep 192.33 | wc -l
   log    ${BGP_RSX1}
   IF    ${BGP_RSX} == 0 or ${BGP_RSX1} == 0
          IF    ${BGP_RSX} < ${BGP_RSX1} and ${BGP_RSX1} == 0
                Fail    log     Public DNS 170.199.xx.xx is not initialized.
          ELSE IF    ${BGP_RSX1} < ${BGP_RSX} and ${BGP_RSX} == 0
                Fail    log     Public DNS 192.33.xx.xx is not initialized.
          ELSE IF    ${BGP_RSX} == 1 or ${BGP_RSX1} == 1
                log    Public DNS for RSX is Fine.
          END
   ELSE IF  ${BGP_RSX} == 0 and ${BGP_RSX1} == 0
          Fail    log   Some issue is going with Public DNS. Please Check.
   END

Check Internal DNS for RSX
   [Arguments]    ${ip}    ${username}    ${password}
   ${BGP_RSX}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "sh ip bgp"' | grep -E '\\b(194\\.35|185\\.123)\\.' | wc -l
   log    ${BGP_RSX}
   IF    ${BGP_RSX} < 6
          Fail    log     One or more internal DNS 194.35.xx.xx is not initialized.
    ELSE
         log    Internal DNS for RSX is Fine.
    END

Check Hops to BR for RSX
   [Arguments]    ${ip}    ${username}    ${password}
   ${BGP_RSX}=    execute command    echo ${password} | sudo -S ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} sudo -S 'vtysh -c "sh ip bgp"' | grep 172.31.11 | wc -l
   log    ${BGP_RSX}
   IF    ${BGP_RSX} < 2
          Fail    log     One or both next hops to BRs are disconnected.
   ELSE
         log    One or both next hops to BRs are connected.
   END

Check All RSX Services
    [Arguments]    ${ip}    ${username}    ${password1}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
    Establish Connection and Log In to AMB LAX directly
    run keyword and continue on failure    Check RSX Number of Global Ip Addresses   ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check RSX answerx Services    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Find DNS IP to check Internet Connectivity RSX   ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check TCP Statistics RSX   ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check All ABR sockets are connected for TCP RSX    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check All BR sockets are connected for TCP RSX    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check BGP Statistics for RSX   ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check IP BGP Statistics for RSX    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Public DNS for RSX    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Internal DNS for RSX    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Hops to BR for RSX    ${ip}    ${username}    ${password}
    close all connections


RSX Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["RSX"]}
    Log  ${properties}
    @{Failed_RSXs}=    Create List
    @{Passed_RSXs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All RSX Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    RSX services report is not fine. Please Check 'Check All RSX Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_RSXs}   ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_RSXs}   ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed RSXs: ${Passed_RSXs}   Passed RSXs Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All RSX's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed RSX's    Log Many    Failed RSXs: ${Failed_RSXs}    Failed RSXs Count: ${fail}    Please Check RSX Services in logs for ${Failed_RSXs}

    END

Check cibr-lrd.service status for CIBR
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status cibr-lrd.service | egrep \"Loaded\|Active\|PID\"
   log    ${CIBR_check}
   should contain    ${CIBR_check}    ${running}    msg=Something wrong please check the cibr-lrd.service    values=False

Check cibr-rd-1.service status for CIBR
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status cibr-rd-1.service | egrep \"Loaded\|Active\|PID\"
   log    ${CIBR_check}
   should contain    ${CIBR_check}    ${running}    msg=Something wrong please check the cibr-rd-1.service    values=False

Check cibr-rd-2.service status for CIBR
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status cibr-rd-2.service | egrep \"Loaded\|Active\|PID\"
   log    ${CIBR_check}
   should contain    ${CIBR_check}    ${running}    msg=Something wrong please check the cibr-rd-2.service    values=False

Check CIBP connectivity for CIBR PEER1
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "grep PEER_1 /etc/opt/cibr/cibr.conf | cut -f 2 -d ="
   log    ${CIBR_check}
   IF    "${CIBR_check}" == "${empty}"
          Fail    log     CIBP is not configured
   ELSE
        log    CIBP is configured
   END
   [Return]    ${CIBR_check}

Check CIBP connectivity for CIBR PEER2
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check1}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "grep PEER_2 /etc/opt/cibr/cibr.conf | cut -f 2 -d ="
   log    ${CIBR_check1}
   IF    "${CIBR_check1}" == "${empty}"
          Fail    log     CIBP is not configured
   ELSE
        log    CIBP is configured
   END
   [Return]    ${CIBR_check1}

Check TCP Connections for Both CIBP
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBP1}=    Check CIBP connectivity for CIBR PEER1    ${ip}    ${username}    ${password}
   log    ${CIBP1}
   ${CIBP2}=    Check CIBP connectivity for CIBR PEER2    ${ip}    ${username}    ${password}
   log    ${CIBP2}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} ss | grep tcp | grep 172.30.1 | grep ESTAB | awk '{ print $6 }' | egrep "${CIBP1}|${CIBP2}" | wc -l
   log    ${CIBR_check}
   IF    ${CIBR_check} < 2
          Fail    log     TCP:One or both CIBP connections are down
   ELSE
         log     TCP:Both CIBP connections are up
   END

Check TCP Connections for CIBP1
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBP1}=    Check CIBP connectivity for CIBR PEER1    ${ip}    ${username}    ${password}
   log    ${CIBP1}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "timeout 11 tcpdump -p -i ens192 -nn src ${CIBP1} -c 2" | grep ${CIBP1} | wc -l
   log    ${CIBR_check}
   IF    ${CIBR_check} > 0
          log     TCP: ${CIBP1} connection is up for CIBP1
   ELSE
         Fail    log     ${CIBP1} connection is down for CIBP1
   END

Check TCP Connections for CIBP2
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBP2}=    Check CIBP connectivity for CIBR PEER2    ${ip}    ${username}    ${password}
   log    ${CIBP2}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "timeout 11 tcpdump -p -i ens192 -nn src ${CIBP2} -c 2" | grep ${CIBP2} | wc -l
   log    ${CIBR_check}
   IF    ${CIBR_check} > 0
          log     TCP: ${CIBP2} connection is up for CIBP2
   ELSE
         Fail    log     ${CIBP2} connection is down for CIBP2
   END

Check cibr lrd service status for CIBR
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status lrd | egrep \"Loaded\|Active\|PID\"
   log    ${CIBR_check}
   should contain    ${CIBR_check}    ${running}    msg=Something wrong please check the cibr lrd service    values=False

Check cibr rd-0 service status for CIBR
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status rd@0 | egrep \"Loaded\|Active\|PID\"
   log    ${CIBR_check}
   should contain    ${CIBR_check}    ${running}    msg=Something wrong please check the cibr rd 0 service    values=False

Check cibr rd-1 service status for CIBR
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status rd@1 | egrep \"Loaded\|Active\|PID\"
   log    ${CIBR_check}
   should contain    ${CIBR_check}    ${running}    msg=Something wrong please check the cibr rd 1 service    values=False

Check CIBP1 connectivity for CIBR
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep Servers.from /etc/rd@0.d/rd.toml -A 4 | grep IP | grep -v "#" | xargs | awk '{ print $3 }'
   log    ${CIBR_check}
   IF    "${CIBR_check}" == "${empty}"
          Fail    log     CIBP is not configured
   ELSE
        log    CIBP is configured
   END
   [Return]    ${CIBR_check}

Check CIBP2 connectivity for CIBR
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBR_check1}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep Servers.from /etc/rd@1.d/rd.toml -A 4 | grep IP | grep -v "#" | xargs | awk '{ print $3 }'
   log    ${CIBR_check1}
   IF    "${CIBR_check1}" == "${empty}"
          Fail    log     CIBP is not configured
   ELSE
        log    CIBP is configured
   END
   [Return]    ${CIBR_check1}

Check TCP Traffic Flow Connections for CIBP1
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBP1}=    Check CIBP1 connectivity for CIBR    ${ip}    ${username}    ${password}
   log    ${CIBP1}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "timeout 11 tcpdump -p -i eth1 -nn src ${CIBP1} -c 2" | grep ${CIBP1} | wc -l
   log    ${CIBR_check}
   IF    ${CIBR_check} > 0
          log     TCP: ${CIBP1} connection is up for CIBP1
   ELSE
         Fail    log     ${CIBP1} connection is down for CIBP1
   END

Check TCP Traffic Flow Connections for CIBP2
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBP2}=    Check CIBP2 connectivity for CIBR    ${ip}    ${username}    ${password}
   log    ${CIBP2}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "timeout 11 tcpdump -p -i eth1 -nn src ${CIBP2} -c 2" | grep ${CIBP2} | wc -l
   log    ${CIBR_check}
   IF    ${CIBR_check} > 0
          log     TCP: ${CIBP2} connection is up for CIBP2
   ELSE
         Fail    log     ${CIBP2} connection is down for CIBP2
   END

Check TCP Traffic Flow Connections for Both CIBP
   [Arguments]    ${ip}    ${username}    ${password}
   ${CIBP1}=    Check CIBP1 connectivity for CIBR    ${ip}    ${username}    ${password}
   log    ${CIBP1}
   ${CIBP2}=    Check CIBP2 connectivity for CIBR    ${ip}    ${username}    ${password}
   log    ${CIBP2}
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} ss | grep tcp | grep ESTAB | awk '{ print $6 }' | egrep "${CIBP1}|${CIBP2}" | wc -l
   log    ${CIBR_check}
   IF    ${CIBR_check} < 2
          Fail    log     TCP:One or both CIBP connections are down
   ELSE
         log     TCP:Both CIBP connections are up
   END

Check All CIBR Services
   [Arguments]    ${ip}    ${username}    ${password1}
   ${password}=    Get Decrypted Text    ${password1}
   log    ${password}
   Establish Connection and Log In to AMB LAX directly
   ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} -t ${username}@${ip} "lrd -v"
   log    ${CIBR_check}
   ${count}    get length    ${CIBR_check}
   log    ${count}
   IF    $out in $CIBR_check
         Fail    log    Server does not exist
   ELSE IF    $not_found in $CIBR_check
         run keyword and continue on failure    Check cibr-lrd.service status for CIBR    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check cibr-rd-1.service status for CIBR    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check cibr-rd-2.service status for CIBR    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check CIBP connectivity for CIBR PEER1    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check CIBP connectivity for CIBR PEER2    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check TCP Connections for CIBP1    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check TCP Connections for CIBP2    ${ip}    ${username}    ${password}
         run keyword and continue on failure    Check TCP Connections for Both CIBP    ${ip}    ${username}    ${password}
   ELSE IF    ${count} == 0
         Fail    log    Server does not exist
   ELSE
        ${CIBR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} -t ${username}@${ip} "lrd -v" | awk '{gsub(/[()]/,"",$NF); print $NF}' | sed 's/Ltd\.//g'
        log    ${CIBR_check}
        run keyword and continue on failure    Check cibr lrd service status for CIBR    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check cibr rd-0 service status for CIBR    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check cibr rd-1 service status for CIBR    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check CIBP1 connectivity for CIBR    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check CIBP2 connectivity for CIBR    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check TCP Traffic Flow Connections for CIBP1    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check TCP Traffic Flow Connections for CIBP2    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check TCP Traffic Flow Connections for Both CIBP    ${ip}    ${username}    ${password}
   END
   close all connections


CIBR Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["CIBR"]}
    Log  ${properties}
    @{Failed_CIBRs}=    Create List
    @{Passed_CIBRs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All CIBR Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    CIBR services report is not fine. Please Check 'Check All CIBR Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_CIBRs}   ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_CIBRs}   ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed CIBRs: ${Passed_CIBRs}   Passed CIBRs Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All CIBR's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed CIBR's    Log Many    Failed CIBRs: ${Failed_CIBRs}   Failed CIBRs Count: ${fail}    Please Check CIBR Services in logs for ${Failed_CIBRs}

    END

Check Ip Address connectivity for DCR
   [Arguments]    ${ip}    ${username}    ${password}
   ${DCR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} 'ip addr | grep global | wc -l'
   log    ${DCR_check}
   ${count}    get length    ${DCR_check}
   log    ${count}
   IF    $cto in $DCR_check
         Fail    log    Server does not exist
   ELSE IF    ${count} == 0
         Fail    log    Server does not exist
   ELSE IF    ${DCR_check} < 7
         Fail    log    Something wrong, as the ip addr spwaned are ${DCR_check}, which is less than expected count of 7.
   ELSE IF    ${DCR_check} > 7
        Fail    log    Something wrong, as the ip addr spwaned are ${DCR_check}, which is more than expected count of 7.
   ELSE
        log    ip addr loops good as all IPs including loopback are instantiated.
   END

Check bind9.service for DCR
   [Arguments]    ${ip}    ${username}    ${password}
   ${DCR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status bind9.service | egrep "Loaded|Active|Process|PID"
   log    ${DCR_check}
   should contain    ${DCR_check}    ${running1}    msg=Something wrong please check the bind9 service    values=False

Check networking.service running status for DCR
   [Arguments]    ${ip}    ${username}    ${password}
   ${DCR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} 'systemctl status networking.service'
   log    ${DCR_check}
   should contain    ${DCR_check}    ${pass_status}    msg=Something wrong with the networking service    values=False

Check DNS address and Internet Reachability for DCR
   [Arguments]    ${ip}    ${username}    ${password}
   ${DCR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /etc/network/interfaces.d/lo.cfg | grep address | head -1 | xargs | cut -f 2 -d " " | cut -f 1 -d "/"
   log    ${DCR_check}
   IF    "${DCR_check}" == "${empty}"
         ${DCR_check1}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /etc/network/interfaces.d/lo1.cfg | grep address | head -1 | xargs | cut -f 2 -d " " | cut -f 1 -d "
         log    ${DCR_check1}
         should not contain    ${DCR_check1}    ${empty}    msg=Something is wrong with DCR.Please Check  values=False
         ${DCR_internet_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping 1.1.1.1 -I ${DCR_check} -c 2"
         log    ${DCR_internet_check}
         should not contain    ${DCR_internet_check}    ${Destination_Host_Unreachable}
         should not contain    ${DCR_internet_check}    ${Something_is_wrong}
         should contain      ${DCR_internet_check}     ${64byts}
   ELSE
         log    ${DCR_check}
         ${DCR_internet_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping 1.1.1.1 -I ${DCR_check} -c 2"
         log    ${DCR_internet_check}
         should not contain    ${DCR_internet_check}    ${Destination_Host_Unreachable}
         should not contain    ${DCR_internet_check}    ${Something_is_wrong}
         should contain      ${DCR_internet_check}     ${64byts}
   END

Check BGP Stats for DCR
    [Arguments]    ${ip}    ${username}    ${password}
    ${DCR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp sum\\"
    log    ${DCR_check}
    ${count}    get length    ${DCR_check}
    log    ${count}
    IF    ${count} == 0
          Fail    log    Server is not reachable
    ELSE
          ${resp_count}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp sum\\" | grep 172.31 | awk '{ print $10 }' | grep [a-z,A-Z] | wc -l
          log    ${resp_count}
          IF    ${resp_count} == 0
                log    Both BRs are reachable
          ELSE IF    ${resp_count} == 2
                Fail    log     Both BRs are down
          ELSE
                ${BR1}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp sum\\" | grep 172.31 | head -1 | awk '{ print $1 }'
                ${BR1_Status}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp sum\\" | grep 172.31 | head -1 | awk '{ print $10 }' | grep [a-z,A-Z] | wc -l
                run keyword and continue on failure    should not be equal    ${BR1_Status}    1    msg= Issue with BR "${BR1}"    values=False
                ${BR2}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp sum\\" | grep 172.31 | tail -1 | awk '{ print $1 }'
                ${BR2_Status}=    Execute Command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp sum\\" | grep 172.31 | tail -1 | awk '{ print $10 }' | grep [a-z,A-Z] | wc -l
                run keyword and continue on failure    should not be equal    ${BR2_Status}    1    msg= Issue with BR "${BR2}"    values=False
          END
    END

Check loopback IPS Spawned or not for DCR
    [Arguments]    ${ip}    ${username}    ${password}
    ${DCR_check}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"sh ip bgp\\"
    log    ${DCR_check}
    ${loopback}=    execute command    echo "${DCR_check}" | grep -v BGP | grep -E '192.33|170.199' | wc -l
    log    ${loopback}
    run keyword and continue on failure    should be equal    ${loopback}    5    msg=One or more of 5 loopback IPs are not spawned    values=False
    ${nexthops}=    execute command    echo "${DCR_check}" | grep 172.31 | wc -l
    log    ${nexthops}
    IF    ${nexthops} < 2
          Fail    log    One or both next hops to BRs are not connected
    ELSE
          log    One or both next hops to BRs are connected
    END

Check All DCR Services
    [Arguments]    ${ip}    ${username}    ${password1}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
    Establish Connection and Log In to AMB LAX directly
    run keyword and continue on failure    Check Ip Address connectivity for DCR    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check bind9.service for DCR    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check networking.service running status for DCR    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check DNS address and Internet Reachability for DCR    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check BGP Stats for DCR    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check loopback IPS Spawned or not for DCR    ${ip}    ${username}    ${password}
    close all connections

DCR Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["DCR"]}
    Log  ${properties}
    @{Failed_DCRs}=    Create List
    @{Passed_DCRs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All DCR Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    DCR services report is not fine. Please Check 'Check All DCR Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_DCRs}   ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_DCRs}   ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed DCR: ${Passed_DCRs}   Passed DCR Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All DCR's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed DCR's    Log Many    Failed DCRs: ${Failed_DCRs}   Failed DCRs Count: ${fail}    Please Check DCR Services in logs for ${Failed_DCRs}

    END

Check Collector Cluster is Online
    [Arguments]    ${ip}    ${username}    ${password}
    ${colout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} pcs status | grep Online
    log    ${colout}
    IF    $cto in $colout
        Fail    Log    Collector Does not exist
    ELSE IF    $online in $colout
        Log    COL1 and COL2 Cluster are Online
    ELSE IF    $offline in $colout
        Fail    log    COL1 and COL2 Cluster are Offline
    ELSE
        Fail    log    Something is wrong please check in Collectors
    END

Check Corosync Status in Collector
    [Arguments]    ${ip}    ${username}    ${password}
    ${colout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} pcs status | grep corosync
    log    ${colout}
    IF    $enable in $colout
        Log    corosync service is running fine in Collector
    ELSE
        Fail    log    Something is wrong please check the corosync service in Collectors
    END

Check Pacemaker Status in Collector
    [Arguments]    ${ip}    ${username}    ${password}
    ${colout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} pcs status | grep pacemaker
    log    ${colout}
    IF    $enable in $colout
        Log    pacemaker Service is running fine in Collector
    ELSE
        Fail    log    Something is wrong please check the pacemaker service in Collector
    END

Check Pcsd Status in Collector
    [Arguments]    ${ip}    ${username}    ${password}
    ${colout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} pcs status | grep pcsd
    log    ${colout}
    IF    $enable in $colout
        Log    pcsd service is running fine in Collector
    ELSE
        Fail    log    Something is wrong please check the pcsd service in Collector
    END

Check Collector ID in Collector
    [Arguments]    ${ip}    ${username}    ${password}
    ${colout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /etc/grpcollr.d/config_col.toml | grep collector_id | awk -F'"' '{ print $2 }'
    log    ${colout}
    ${sitename}    get regexp matches    ${colout}    ${site_name_rgx}
    @{ALLOWED}=   create list    ATL01    DFW01    EWR01    FRA04    FRA08    IAD01    LAX01    LON01    MAD01    MEL01    ORD01    PAR01    QRO01    SYD01    TYO01    YMQ01    GRU01    DUB01    LON02
    FOR    ${item}    IN    @{sitename}
        log    ${item}
        ${PAGE}=  set variable  ${item}
        IF  $PAGE not in $ALLOWED
            Fail    log    Collector ID is not Valid
        ELSE
            Log    This is the Collector ID of '${PAGE}' Site
        END
    END
    ${site}    should match regexp    ${colout}    ${collector_ID_rgx}
    Log    This is valid Collector ID

Check ntp server IP in Collector
    [Arguments]    ${ip}    ${username}    ${password}
    ${colout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /etc/grpcollr.d/config_col.toml | grep ntp_srv | grep 172.16
    log    ${colout}
    should match regexp    ${colout}    ${IPregex}    msg= Something is wrong with ntp server IP    values=False
    ${len}    get length    ${colout}
    log    ${len}
    IF    ${len} > 27
        Fail    Log    Something is wrong in ntp_srv configuration
    ELSE
        Log    This is valid ntp_srv IP
    END

Check Account Name in Collector
    [Arguments]    ${ip}    ${username}    ${password}
    ${colout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /etc/grpcollr.d/config_col.toml | grep collector_id | awk -F'"' '{ print $2 }'
    log    ${colout}
    ${sitename}    get regexp matches    ${colout}    ${site_name_rgx}
    log    ${sitename}
    ${colout1}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /etc/grpcollr.d/config_col.toml | grep spooler_dir
    log    ${colout}
    ${cpra_out}    get regexp matches    ${colout1}    ${cpra_rgx}
    ${str}    convert to string      ${cpra_out}[0]
    ${final_cpra}    replace string using regexp    ${str}    ${whitespace_regex}    ${empty}
    ${colout1}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} cat /etc/grpcollr.d/config_spl_${final_cpra}_dnf.toml | grep accnt
    log    ${colout1}
    @{USlist}    create list    ATL01    DFW01    EWR01   IAD01    LAX01    ORD01    QRO01    YMQ01
    @{UKlist}    create list    LON01    MAD01    PAR01    FRA08    DUB01    LON02
    @{APAClist}    create list    HKG01    MEL01    SYD01    TYO01
    @{STGlist}    create list    FRA04
    FOR    ${item}    IN    @{sitename}
        log    ${item}
        ${PAGE}=  set variable  ${item}
        IF    $item in $USlist
            should contain    ${final_cpra}    cpra-us    msg= Someting is wrong in spooler_dir     values=False
            should contain    ${colout1}    probestorageusanalytics    msg= Someting is wrong in Collector Service    values=False
        ELSE IF    $item in $UKlist
            should contain    ${final_cpra}    cpra-eu    msg= Someting is wrong in spooler_dir     values=False
            should contain    ${colout1}    probestorageeuanalytics    msg= Someting is wrong in Collector Service    values=False
        ELSE IF    $item in $STGlist
            should contain    ${final_cpra}    cpra-stg    msg= Someting is wrong in spooler_dir     values=False
            should contain    ${colout1}    probesnltx2eustaging    msg= Someting is wrong in Collector Service    values=False
        ELSE IF     $item in $APAClist
            should contain    ${final_cpra}    cpra-apac    msg= Someting is wrong in spooler_dir     values=False
            should contain    ${colout1}    probestorageapanalytics    msg= Someting is wrong in Collector Service    values=False
        ELSE
            Fail    log     spooler_dir or Account Name is Missing
        END
    END

Check Collector Service Status
    [Arguments]    ${ip}    ${username}    ${password}
    ${colout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status collector.service | egrep \"Loaded\|Active\|PID\"
    log    ${colout}
    should contain    ${colout}    ${active_run}    msg= Someting is wrong in Collector Service    values=False

Check All COL Services
    [Arguments]    ${ip}    ${username}    ${password1}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
    Establish Connection and Log In to AMB LAX directly
    run keyword and continue on failure    Check Collector Cluster is Online    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Corosync Status in Collector    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Pacemaker Status in Collector    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Pcsd Status in Collector    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Collector ID in Collector    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check ntp server IP in Collector    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Account Name in Collector    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Collector Service Status    ${ip}    ${username}    ${password}
    close all connections

COL Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["COL"]}
    Log  ${properties}
    @{Failed_COLs}=    Create List
    @{Passed_COLs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All COL Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    Collector services report is not fine. Please Check 'Check All COL Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_COLs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_COLs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed COLS: ${Passed_COLs}    Passed COLS Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All COL's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed COL's    Log Many    Failed COLS: ${Failed_COLs}    Failed COLS Count: ${fail}    Please Check COL Services in logs for ${Failed_COLs}

    END

Check All WCS Services
    [Arguments]    ${ip}    ${username}    ${password1}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
    Establish Connection and Log In to AMB LAX directly
    ${wcsout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep mcast /etc/zvelo.d/zvelo.conf
    log    ${wcsout}
    IF    $cto in $wcsout
        Fail    Log    WCS Server does not exist
    ELSE IF    $mcast in $wcsout
        log    WCS Server is connected
        run keyword and continue on failure    Check zvelo server service in WCS   ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check zvelo database downloader service in WCS    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check zvelo database updater service in WCS    ${ip}    ${username}    ${password}
        run keyword and continue on failure    Check mcast interface and mcast group verification in WCS    ${ip}    ${username}    ${password}
    ELSE
        Fail    log    Something is wrong with /etc/zvelo.d/zvelo.conf file in WCS Server
    END
    close all connections

Check zvelo server service in WCS
    [Arguments]    ${ip}    ${username}    ${password}
    ${wcsout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status zvelo-server.service | egrep "Loaded|Active|PID"
    log    ${wcsout}
    IF    $active_run in $wcsout
        Log    zvelo-server service is running fine in WCS
    ELSE
        Fail    Log    Something is wrong please check the zvelo server service in WCS
    END

Check zvelo database downloader service in WCS
    [Arguments]    ${ip}    ${username}    ${password}
    ${wcsout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status zvelo-database-downloader.service | egrep "Loaded|Active|PID"
    log    ${wcsout}
    IF    $failed_status in $wcsout
        Fail    Log    Something is wrong please check the zvelo database downloader service in WCS
    ELSE
        Log    zvelo database downloader service is running fine in WCS
    END

Check zvelo database updater service in WCS
    [Arguments]    ${ip}    ${username}    ${password}
    ${wcsout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status zvelo-database-updater.service | egrep "Loaded|Active|PID"
    log    ${wcsout}
    IF    $failed_status in $wcsout
        Fail    Log    Something is wrong please check the zvelo database updater service in WCS
    ELSE
        Log    zvelo database updater service is running fine in WCS
    END

Check mcast interface and mcast group verification in WCS
    [Arguments]    ${ip}    ${username}    ${password}
    ${wcsout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep mcast /etc/zvelo.d/zvelo.conf
    log    ${wcsout}
    ${mcastintip}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep 172.30 /etc/network/interfaces | xargs | cut -f 2 -d " "
    log    ${mcastintip}
    IF    $mcastintip in $wcsout
        Log     mcast interface ip set in WCS
    ELSE
        Fail    Log    Something is wrong with mcast interface ip configuration in /etc/zvelo.d/zvelo.conf file
    END
    IF    $mcastgroup in $wcsout
        Log    mcast group ip set in WCS
    ELSE
        Fail    Log    Something is wrong with mcast_group configuration in /etc/zvelo.d/zvelo.conf file
    END

WCS Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["WCS"]}
    Log  ${properties}
    @{Failed_WCSs}=    Create List
    @{Passed_WCSs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All WCS Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    WCS services report is not fine. Please Check 'Check All WCS Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_WCSs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_WCSs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed WCS: ${Passed_WCSs}    Passed WCS Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All WCS's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed WCS's    Log Many    Failed WCS: ${Failed_WCSs}    Failed WCS Count: ${fail}    Please Check WCS Services in logs for ${Failed_WCSs}

    END

Check squid service status
    [Arguments]    ${ip}    ${username}    ${password}
    ${squidout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status squid.service | egrep "Loaded|Active|Process|PID"
    log    ${squidout}
    IF    $active_run in $squidout
        Log    Squid Service is running in Prod Server
    ELSE
        Fail    log    Squid Service is down in Prod Server
    END

Check pacemaker service status
    [Arguments]    ${ip}    ${username}    ${password}
    ${pacemakerout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} systemctl status pacemaker.service | egrep "Loaded|Active|Process|PID"
    IF    $active_run in $pacemakerout
        Log    Pacemaker Service is running in Prod Server
    ELSE
        Fail    log    Pacemaker Service is down in Prod Server
    END

Check Internet reachability for Prod Service
    [Arguments]    ${ip}    ${username}    ${password}
    ${internetout}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} "ping 1.1.1.1 -I eth0 -c 2"
    Log    ${internetout}
    should not contain    ${internetout}    ${Destination_Host_Unreachable}     msg=Internet not working in Prod Server   values=False
    should not contain    ${internetout}    ${Something_is_wrong}    msg=Internet not working in Prod Server  values=False
    should contain      ${internetout}     ${64byts}    msg=Internet is working in Prod Server   values=False

Check Cluster Count
    [Arguments]    ${ip}    ${username}    ${password}
    ${cluster}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} grep cluster /etc/hosts | wc -l
    log    ${cluster}
    IF    "${cluster}" == "0"
        Log    cluster configurations are missing in /etc/hosts file
    ELSE IF    "${cluster}" == "1"
        Log    cluster configurations are missing in /etc/hosts file
    ELSE
        Log    cluster configurations is fine
    END

Check All PROD Services
    [Arguments]    ${ip}    ${username}    ${password1}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
    Establish Connection and Log In to AMB LAX directly
    run keyword and continue on failure    Check squid service status    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check pacemaker service status    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Internet reachability for Prod Service    ${ip}    ${username}    ${password}
    run keyword and continue on failure    Check Cluster Count    ${ip}    ${username}    ${password}
    close all connections

PROD Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["PROD-PRX"]}
    Log  ${properties}
    @{Failed_PRODs}=    Create List
    @{Passed_PRODs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All PROD Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    PROD services report is not fine. Please Check 'Check All PROD Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_PRODs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_PRODs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed PRODS: ${Passed_PRODs}    Passed PRODS Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All PROD's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed PROD's    Log Many    Failed PRODS: ${Failed_PRODs}    Failed PRODS Count: ${fail}    Please Check PROD Services in logs for ${Failed_PRODs}

    END

Check All VPNNAT Services
    [Arguments]    ${ip}    ${username}    ${password1}
    Establish Connection and Log In to AMB LAX directly
    Check for authentication of hosts before running tests    ${ip}
    ${password}=    Get Decrypted Text    ${password1}
    log    ${password}
    ${bgpout}=    write    ${space}${space} ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} nc-cli
    sleep   10s
    ${bgpout}    read until    >
    log    ${bgpout}
    write    show bgp vrf
    sleep   5s
    ${bgpipout}    read
    log   ${bgpipout}
    IF    $notrunning in $bgpipout
        Fail    Log    bgp vrf verification is not running
    ELSE IF    $permission in $bgpout
        Fail    Log    Something is wrong in loging CGNAT Server;CGNAT Server may be not reachable or Password may be wrong
    ELSE IF    $cto in $bgpout
        Fail    Log    CGNAT Server does not exist
    ELSE
        run keyword and continue on failure    Check BRKOUT and BR Interfaces  ${ip}    ${username}    ${password}
    END
    close all connections

Check brkout1 interfaces count
    [Arguments]    ${ip}    ${username}    ${password}
    ${brk1out}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp vrf all summary\\" | grep "^169.254.203" | awk '{ print $1": "$10 }' | grep [a-zA-Z]| wc -l
    Log    ${brk1out}
    IF    ${brk1out} > 0
        Fail    Log    One or both brkout1 connections are down
    ELSE
        Log    brkout1 interfaces are connected
    END

Check brkout2 interfaces count
    [Arguments]    ${ip}    ${username}    ${password}
    ${brk2out}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp vrf all summary\\" | grep "^169.254.213" | awk '{ print $1": "$10 }' | grep [a-zA-Z] | wc -l
    Log    ${brk2out}
    IF    ${brk2out} > 0
        Fail    Log    One or both brkout2 connections are down
    ELSE
        Log    brkout2 interfaces are connected
    END

Check brkout3 interfaces count
    [Arguments]    ${ip}    ${username}    ${password}
    ${brk3out}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp vrf all summary\\" | grep "^169.254.223" | awk '{ print $1": "$10 }' | grep [a-zA-Z] | wc -l
    Log    ${brk3out}
    IF    ${brk3out} > 0
        Fail    Log    One or both brkout3 connections are down
    ELSE
        Log    brkout3 interfaces are connected
    END

Check BR interfaces count
    [Arguments]    ${ip}    ${username}    ${password}
    ${brint}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} vtysh -c \\"show bgp vrf all summary\\" | grep "^172.31" | awk '{ print $1": "$10 }' | grep [a-zA-Z] | wc -l
    Log    ${brint}
    IF    ${brint} > 0
        Fail    Log    One or both BR connections are down
    ELSE
        Log    BR interfaces are connected
    END


Check BRKOUT and BR Interfaces
    [Arguments]    ${ip}    ${username}    ${password}
    Establish Connection and Log In to AMB LAX directly
    write    ${space}${space} ${ssh_command} ${password} ${ssh_o_command} ${username}@${ip} nc-cli
    sleep   10s
    ${bgpout}    read until    >
    log    ${bgpout}
    write    show bgp vrf
    sleep   5s
    ${output1}    read
    log   ${output1}
    ${count}=    get regexp matches    ${output1}     ${brkout_rgx}
    log     ${count}
    FOR    ${key}    IN    @{count}
        write    show bgp vrf ${key} summary
        sleep    5s
        ${out1}=    read
        log  ${out1}
        ${new_str1}   remove string using regexp    ${out1}    ${cmd_data_regex}
        log    ${new_str1}
        ${new_str}   remove string using regexp    ${new_str1}    ${peer_regex}
        log    ${new_str}
        ${new_str1}   remove string using regexp   ${new_str}    ${cmd_data_total_regex_nccli}
        log    ${new_str1}
        ${txt_file}     create file     ${EXECDIR}/${dff_dir_bgp}/${BGP_Status_txt}    ${new_str1}
        create file    ${EXECDIR}/${dff_dir_bgp}/${BGP_out_final}
        ${csv_file}     get txt file    ${EXECDIR}/${dff_dir_bgp}/${BGP_Status_txt}     ${EXECDIR}/${dff_dir_bgp}/${BGP_out_final}
        ${data}    OperatingSystem.get file       ${EXECDIR}/${dff_dir_bgp}/${BGP_out_final}
        ${new}      replace string using regexp    ${data}      ${whitespace_regex}    ${comma_seperator}
        log     ${new}
        ${txt1_file}      create file    ${EXECDIR}/${dff_dir_bgp}/${BGP_check_final}     ${new}
        @{row}=     get column value    ${EXECDIR}/${dff_dir_bgp}/${BGP_check_final}   ${state_column}
        log    ${row}
        @{ALLOWED}=   create list    Idle    Connect    Active    OpenSent    OpenConfirm    never
        FOR    ${item}    IN    @{row}
             log    ${item}
             ${PAGE}=  set variable  ${item}
             IF  $PAGE not in $ALLOWED
                 Log    '${PAGE}' contains Valid Value
             ELSE
                 run keyword and continue on failure    fail  One or More Breakout or BR interface down
             END
        END
    END

VPNNAT Services Check
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["VPNAT"]}
    Log  ${properties}
    @{Failed_VPNNATs}=    Create List
    @{Passed_VPNNATs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check All VPNNAT Services    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    VPNNAT services report is not fine. Please Check 'Check All VPNNAT Services' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_VPNNATs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_VPNNATs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed VPNNAT: ${Passed_VPNNATs}    Passed VPNNAT Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All VPNNAT's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed VPNNAT's    Log Many    Failed VPNNAT: ${Failed_VPNNATs}    Failed VPNNAT Count: ${fail}    Please Check VPNNAT Services in logs for ${Failed_VPNNATs}
   END

Collect Tcpdump on all ABR's
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["ABR"]}
    Log  ${properties}
    @{Failed_DEs}=    Create List
    @{Passed_DEs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Take Tcpdump from ABR    ${sub dict}[ABR-IP]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    TCpdump not taken. Please Check DE sites for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_DEs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_DEs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed DE: ${Passed_DEs}    Passed DE Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All DE's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed DE's    Log Many    Failed DE: ${Failed_DEs}    Failed DE Count: ${fail}    Please Check VMS in logs for ${Failed_DEs}
   END

Kill Tcpdump on all ABR'S
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["ABR"]}
    Log  ${properties}
    @{Failed_DEs}=    Create List
    @{Passed_DEs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Stop Tcpdump in ABR    ${sub dict}[ABR-IP]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    TCpdump not taken. Please Check DE sites for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_DEs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_DEs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed DE: ${Passed_DEs}    Passed DE Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All DE's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed DE's    Log Many    Failed DE: ${Failed_DEs}    Failed DE Count: ${fail}    Please Check VMS in logs for ${Failed_DEs}
   END

Delete Tcpdump on all ABR'S
    [Arguments]    ${site}
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${site}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Site"]["ABR"]}
    Log  ${properties}
    @{Failed_DEs}=    Create List
    @{Passed_DEs}=    Create List
    set test variable    ${check_status}    ${0}
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Delete tcpdump from DE site    ${sub dict}[ABR-IP]   ${sub dict}[username]   ${sub dict}[password1]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    TCpdump not taken. Please Check DE sites for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_DEs}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_DEs}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed DE: ${Passed_DEs}    Passed DE Count: ${pass}
   IF      ${fail} == ${check_status}
            log    All DE's are passing.There is no Failure
    ELSE
           run keyword and continue on failure    Fail    Failed DE's    Log Many    Failed DE: ${Failed_DEs}    Failed DE Count: ${fail}    Please Check VMS in logs for ${Failed_DEs}
   END

Take Tcpdump from ABR
   [Arguments]    ${ABR-IP}    ${username}    ${password1}
   ${password}=    Get Decrypted Text    ${password1}
   log    ${password}
   Establish Connection and Log In to AMB LAX directly
#   ${create_dir}=    execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} mkdir /tmp/tcpdump_files
#   log    ${create_dir}
   ${tcp_dump}=    start command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} /usr/sbin/tcpdump -p -i undlay -nn net 194.35.38.240/28 and port 179 -G 86400 -s 0 -w /tmp/tcpdump_files/RRConnectivity_$(date +\%Y\%m\%d_\%H\%M\%S).pcap
   log    ${tcp_dump}

Stop Tcpdump in ABR
   [Arguments]    ${ABR-IP}    ${username}    ${password1}
   ${password}=    Get Decrypted Text    ${password1}
   log    ${password}
   Establish Connection and Log In to AMB LAX directly
   ${tcpdump_stop}=    Execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} pkill tcpdump
   log    ${tcpdump_stop}

Delete tcpdump from DE site
  [Arguments]    ${ABR-IP}    ${username}    ${password1}
   ${password}=    Get Decrypted Text    ${password1}
   log    ${password}
   Establish Connection and Log In to AMB LAX directly
   ${tcpdump_del}=    Execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} find /tmp/tcpdump_files -type f -name 'RRConnectivity*.pcap' -mtime +2 -exec rm -rf {} +
   log    ${tcpdump_del}

Collect Backups from AMB 12 Machine
    Establish Connection and Log In to AMB LAX 12 directly
    write    source /home/sasures/network-backup/.venv/bin/activate
    ${bgpout}    read until    AMB-LAX01-12
    log    ${bgpout}
    write    cd /home/sasures/network-backup
    ${bgpout}    read until    network-backup
    log    ${bgpout}
    write    ansible-playbook device_backup_git.yaml --ask-vault-pass
    Read Until    password:
    Write    ${vault_password}
    ${output}=    Wait Until Keyword Succeeds    20 min    1min    read until    network-backup
    log     ${output}

Collect Backups from AMB 12 Machine sreuser
    Establish Connection and Log In to AMB LAX 12 directly
    write    source /home/sreuser/de_config_backups/.venv/bin/activate
    ${bgpout}    read until    AMB-LAX01-12
    log    ${bgpout}
    write    cd /home/sreuser/de_config_backups
    ${bgpout}    read until    de_config_backups
    log    ${bgpout}
    write    ansible-playbook device_backup_git.yaml --ask-vault-pass
    Read Until    password:
    Write    ${vault_password}
    ${output}=    Wait Until Keyword Succeeds    20 min    1min    read until    de_config_backups
    log     ${output}