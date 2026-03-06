*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
Library    String
Library    Collections
Resource   ../Variables/globalvariables.robot
Library    ../CustomLibs/csv2.py
Library     CryptoLibrary    variable_decryption=False
Resource   ../Variables/Authentication_variables.robot


*** Variables ***

*** Keywords ***
Establish Connection and Log In Single Server
    ${username}=    Get Decrypted Text    ${Chirag_nms_username}
    log    ${username}
    ${password}=    Get Decrypted Text    ${Chirag_nms_pass}
    log    ${password}
    ${output}    open connection
    ...     ${Host}
    Log    ${output}
    ${Display}    login
    ...     ${username}
    ...     ${password}
    ...    delay = 120
    should contain   ${Display}    Last login


Establish Connection and Log In for Denv-NMS
    ${username}=    Get Decrypted Text    ${Shubham_nms_username}
    log    ${username}
    ${password}=    Get Decrypted Text    ${Shubham_nms_pass}
    log    ${password}
    ${output}     open connection
    ...     ${denv_host}
    Log    ${output}
    ${Display}    login
    ...     ${username}
    ...     ${password}
    ...    delay = 120
    should contain   ${Display}    Last login


Establish Connection and Log In for Denv-NMS EU
    ${username}=    Get Decrypted Text    ${Chirag_nms_username}
    log    ${username}
    ${password}=    Get Decrypted Text    ${Chirag_nms_pass}
    log    ${password}
    ${output}     open connection
    ...     ${Host}
    Log    ${output}
    ${Display}    login
    ...     ${username}
    ...     ${password}
    ...    delay = 120
    should contain   ${Display}    Last login

Establish Connection and Log In for TX-LAX-Root
    ${password}=    Get Decrypted Text    ${TS_LAX_Pass}
    log    ${password}
    Establish Connection and Log In for Denv-NMS
    write    ${SSH_NoCLient_Ask} ${master_username}@${TX-LAX-Root}
    sleep   5sec
    Read Until    Password:
    Write    ${password}

Establish Connection for Jump Server through TS-LAX-root for AMB-LAX
    ${password}=    Get Decrypted Text    ${AMB_Lax_Password}
    log    ${password}
    Establish Connection and Log In for TX-LAX-Root
    write    ${SSH_NoCLient_Ask} ${master_username}@${AMB_LAX01}
    Read Until    password:
    Write    ${password}
    ${output}=    Read Until   ~#
    log     ${output}

Establish Connection for Jump Server through Routing
    ${password}=    Get Decrypted Text    ${password_FRA14}
    log    ${password}
    Establish Connection and Log In Single Server
    write    ${SSH_NoCLient_Ask} ${master_username}@${AMB_FRA14} -p ${FRA14_port}
    Read Until    password:
    Write    ${password}
    ${output}=    Read Until   ~#
    log     ${output}

Establish Connection for Jump Server through FRA14 for AMB-LAX
    ${password}=    Get Decrypted Text    ${AMB_Lax_Password}
    log    ${password}
    Establish Connection for Jump Server through Routing
    write    ${SSH_NoCLient_Ask} ${master_username}@${AMB_LAX01}
    Read Until    password:
    Write    ${password}
    ${output}=    Read Until   ~#
    log     ${output}

Execute Health Check Script
    ${inp}    write    ${Health_check_directory}
    Write  ${Present_working_directory}
    ${output2}=    Read Until   ${Verify_Beanshells}
    log    ${inp}
    log     ${output2}
    write    ${Health_check_execution}   ${site_name}
    ${output3}    read      delay=600sec
    log    ${output3}
    [Return]     ${output3}

Write Health Check Script in File and Verify Parameters
    ${retval}=    Execute Health Check Script
    log    ${retval}
    sleep    10s
    Health Check Script Verification    ${retval}

Health Check Script Verification
   [Arguments]    ${retVal}
   Create File  ${EXECDIR}/${dff_dir}/${Health_check}    ${retVal}
   Verification of Health Check Scripts

Write Variable in File
  [Arguments]  ${variable}
  Create File  ${EXECDIR}/${dff_dir}/${Health_check}    ${variable}

Verification of Health Check Scripts
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    @{lines}    Split to lines     ${contents}
         FOR       ${line}    IN    @{lines}
             log    ${line}    WARN
         END

Establish Verification of Master AAA
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${health}    should match regexp    ${contents}    ${AAA-Master_Regex}
    log    ${health}
    ${id}    fetch from left    ${health}    ${is_word}
    log    ${id}
    ${ping_master}    get regexp matches   ${contents}   ${1st_rgx}${id}${2nd_rgx}${0% packet loss}
    log     ${ping_master}
    FOR    ${ping_master-data}     IN    ${ping_master}[0]
            log    ${ping_master-data}
            should not contain    ${ping_master-data}    ${Destination_Host_Unreachable}
            should not contain    ${ping_master-data}    ${Something_is_wrong}
            should contain      ${ping_master-data}     ${64byts}
    END

Establish Verification of Bacukup AAA
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${health}    should match regexp    ${contents}    ${AAA-Backup_Regex}
    log    ${health}
    ${id}    fetch from left    ${health}    ${is_word}
    log    ${id}
    ${ping_backup}    get regexp matches   ${contents}   ${1st_rgx}${id}${2nd_rgx}${0% packet loss}
    log     ${ping_backup}
    FOR    ${ping_backup-data}     IN    ${ping_backup}[0]
            log    ${ping_backup-data}
            should not contain    ${ping_backup-data}    ${Destination_Host_Unreachable}
            should not contain    ${ping_backup-data}    ${Something_is_wrong}
            should contain      ${ping_backup-data}     ${64byts}
    END

ID of WCS-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${WCS-01-ID}     should match regexp        ${contents}    ${1st_rgx}${WCS}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${WCS-01-ID}
    FOR    ${WCS-1-ID}    IN    ${WCS-01-ID}[0]
            FOR    ${WCS-ID}    IN    ${WCS-1-ID}[0:12]
            log    ${WCS-ID}
            END
    END
    [Return]    ${WCS-ID}


Establish Verification of Zvelo Server services for WCS-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-01-ID}=    ID of WCS-01
    sleep    5sec
    ${WCS-01-zvelo-server}     should match regexp    ${contents}    ${1st_rgx}${WCS-01-ID}${2nd_rgx}${zvelo-server}${2nd_rgx}${running}
    log     ${WCS-01-zvelo-server}
    FOR    ${WCS-01-zvelo-server-data}     IN    ${WCS-01-zvelo-server}[0]
        log    ${WCS-01-zvelo-server-data}
        should not contain    ${WCS-01-zvelo-server-data}      ${failed}
    END

Establish Verification of Zvelo Downloader Services for WCS-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-01-ID}=    ID of WCS-01
    sleep    5sec
    ${WCS-01-zvelo-downloader}     should match regexp      ${contents}     ${1st_rgx}${WCS-01-ID}${2nd_rgx}${zvelo-downloader}${2nd_rgx}${dead}
    log     ${WCS-01-zvelo-downloader}
    FOR    ${WCS-01-zvelo-downloader-data}     IN    ${WCS-01-zvelo-downloader}[0]
        log    ${WCS-01-zvelo-downloader-data}
        should not contain    ${WCS-01-zvelo-downloader-data}      ${failed}
    END

Establish Verification of Zvelo Updater Services for WCS-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-01-ID}=    ID of WCS-01
    sleep    5sec
    ${WCS-01-zvelo-updater}        should match regexp      ${contents}     ${1st_rgx}${WCS-01-ID}${2nd_rgx}${zvelo-updater}${2nd_rgx}${dead}
    FOR    ${WCS-01-zvelo-updater-data}     IN    ${WCS-01-zvelo-updater}[0]
        log     ${WCS-01-zvelo-updater-data}
        should not contain    ${WCS-01-zvelo-updater-data}      ${failed}
    END

Establish Verification of Zvelo Server services for WCS-02
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-02-ID}    should match regexp     ${contents}    ${WCS-02_regex}
    log     ${WCS-02-ID}
    sleep    5sec
    ${WCS-02-zvelo-server}     should match regexp    ${contents}    ${1st_rgx}${WCS-02-ID}${2nd_rgx}${zvelo-server}${2nd_rgx}${dead}
    log     ${WCS-02-zvelo-server}
    FOR    ${WCS-02-zvelo-server-data}    IN    ${WCS-02-zvelo-server}[0]
        log    ${WCS-02-zvelo-server-data}
        should not contain    ${WCS-02-zvelo-server-data}     ${failed}
    END

Establish Verification of Zvelo Downloader services for WCS-02
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-02-ID}    should match regexp    ${contents}    ${WCS-02_regex}
    log     ${WCS-02-ID}
    sleep    5sec
    ${WCS-02-zvelo-downloader}     should match regexp      ${contents}     ${1st_rgx}${WCS-02-ID}${2nd_rgx}${zvelo-downloader}${2nd_rgx}${dead}
    log     ${WCS-02-zvelo-downloader}
    FOR    ${WCS-02-zvelo-downloader-data}     IN    ${WCS-02-zvelo-downloader}[0]
        log    ${WCS-02-zvelo-downloader-data}
        should not contain    ${WCS-02-zvelo-downloader-data}      ${failed}
    END

Establish Verification of Zvelo Updater services for WCS-02
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-02-ID}    should match regexp     ${contents}    ${WCS-02_regex}
    log     ${WCS-02-ID}
    sleep   5sec
   ${WCS-02-zvelo-updater}        should match regexp      ${contents}     ${1st_rgx}${WCS-02-ID}${2nd_rgx}${zvelo-updater}${2nd_rgx}${dead}
    log     ${WCS-02-zvelo-updater}
    FOR    ${WCS-02-zvelo-updater-data}    IN    ${WCS-02-zvelo-updater}[0]
        log    ${WCS-02-zvelo-updater-data}
        should not contain    ${WCS-02-zvelo-updater-data}      ${failed}
    END

ID of COL-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${COL-01-ID}     should match regexp        ${contents}    ${1st_rgx}${COL}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${COL-01-ID}
    FOR    ${COL-1-ID}    IN    ${COL-01-ID}[0]
           FOR    ${COL-ID}    IN    ${COL-1-ID}[0:12]
              log    ${COL-ID}
           END
    END

    [Return]    ${COL-ID}

Establish Verification of Online status of COL-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL-01-ID}=    ID of COL-01
    sleep   5sec
    ${COL01-Online}     should match regexp      ${contents}     ${1st_rgx}${PCSD Status}${2nd_rgx}${COL-01-ID}${cluster}${2nd_rgx}${Online}
    log     ${COL01-Online}
    FOR    ${COL-online}    IN    ${COL01-Online}[0]
            log    ${COL-online}
            should match regexp    ${COL-online}    ${1st_rgx}${PCSD Status}${2nd_rgx}${COL-01-ID}${cluster}: ${ONLINE}
    END

Establish Verification of Collector Service for COL-01 for pacemaker status
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL-01-ID}=    ID of COL-01
    sleep    5sec
    ${COL01-pacemaker}     should match regexp      ${contents}     ${1st_rgx}${COL-01-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${pacemaker}${2nd_rgx}${active/enabled}
    log     ${COL01-pacemaker}
    FOR    ${COL01-pacemaker-data}     IN    ${COL01-pacemaker}[0]
           log    ${COL01-pacemaker-data}
           should contain    ${COL01-pacemaker-data}    ${pacemaker}: ${active/enabled}
    END

Establish Verification of Collector Service for COL-01 for corosync status
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL-01-ID}=    ID of COL-01
    sleep    5sec
    ${COL01-corosync}     should match regexp      ${contents}     ${1st_rgx}${COL-01-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${corosync}${2nd_rgx}${active/enabled}
    log     ${COL01-corosync}
    FOR    ${COL01-corosync-data}     IN    ${COL01-corosync}[0]
           log    ${COL01-corosync-data}
           should contain    ${COL01-corosync-data}    ${corosync}: ${active/enabled}
    END

Establish Verification of Collector Service for COL-01 for pcsd status
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL-01-ID}=    ID of COL-01
    sleep    5sec
    ${COL01-pcsd}     should match regexp      ${contents}     ${1st_rgx}${COL-01-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${pcsd}${2nd_rgx}${active/enabled}
    log     ${COL01-pcsd}
    FOR    ${COL01-pcsd-data}     IN    ${COL01-pcsd}[0]
           log    ${COL01-pcsd-data}
           should contain    ${COL01-pcsd-data}    ${pcsd}: ${active/enabled}
    END

Establish Verification of Online status of COL-02
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL-02-ID}     should match regexp        ${contents}    ${COL-02_regex}
    log    ${COL-02-ID}
    ${col-2-ID}    fetch from right    ${COL-02-ID}     ${cluster}
    log     ${col-2-ID}
    ${COL02-Online}     should match regexp      ${contents}     ${1st_rgx}${PCSD Status}${2nd_rgx}${col-2-ID}${cluster}${2nd_rgx}${Online}
    log     ${COL02-Online}
    FOR    ${COL-online}    IN    ${COL02-Online}[0]
            log    ${COL-online}
            should match regexp    ${COL-online}    ${1st_rgx}${PCSD Status}${2nd_rgx}${col-2-ID}${cluster}: ${ONLINE}
    END

Establish Verification of Collector Service for COL-02 for pacemaker Status
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL-02-ID}     should match regexp        ${contents}    ${COL-02_regex}
    log    ${COL-02-ID}
    ${COL02-pacemaker}     should match regexp      ${contents}     ${1st_rgx}${COL-02-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${pacemaker}${2nd_rgx}${active/enabled}
    log     ${COL02-pacemaker}
    FOR    ${COL02-pacemaker-data}     IN    ${COL02-pacemaker}[0]
           log    ${COL02-pacemaker-data}
           should contain    ${COL02-pacemaker-data}    ${pacemaker}: ${active/enabled}
    END

Establish Verification of Collector Service for COL-02 for corosync Status
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL-02-ID}     should match regexp        ${contents}    ${COL-02_regex}
    log    ${COL-02-ID}
    ${COL02-corosync}     should match regexp      ${contents}     ${1st_rgx}${COL-02-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${corosync}${2nd_rgx}${active/enabled}
    log     ${COL02-corosync}
    FOR    ${COL02-corosync-data}     IN    ${COL02-corosync}[0]
           log    ${COL02-corosync-data}
           should contain    ${COL02-corosync-data}    ${corosync}: ${active/enabled}
    END

Establish Verification of Collector Service for COL-02 for pcsd Status
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL-02-ID}     should match regexp        ${contents}    ${COL-02_regex}
    log    ${COL-02-ID}
    ${COL02-pcsd}     should match regexp      ${contents}     ${1st_rgx}${COL-02-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${pcsd}${2nd_rgx}${active/enabled}
    log     ${COL02-pcsd}
    FOR    ${COL02-pcsd-data}     IN    ${COL02-pcsd}[0]
           log    ${COL02-pcsd-data}
           should contain    ${COL02-pcsd-data}    ${pcsd}: ${active/enabled}
    END

Establish Verification Connectivity Between CORE and XEPA-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${XEPA-01-ID}     should match regexp        ${contents}    ${1st_rgx}${XEPA}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${XEPA-01-ID}
    FOR    ${XEPA-1-ID}    IN    ${XEPA-01-ID}[0]
           FOR    ${XEPA-ID}    IN    ${XEPA-1-ID}[0:12]
              log    ${XEPA-ID}
           END
    END
    ${ping_master}    get regexp matches   ${contents}   ${1st_rgx}${XEPA-ID}${2nd_rgx}${0% packet loss}
    log     ${ping_master}
    FOR    ${ping_master-data}     IN    ${ping_master}[0]
            log    ${ping_master-data}
            should not contain    ${ping_master-data}    ${Destination_Host_Unreachable}
            should not contain    ${ping_master-data}    ${Something_is_wrong}
            should contain      ${ping_master-data}     ${64byts}
    END

Establish Verification Connectivity Between CORE and XEPA-02
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${XEPA-02-ID}    should match regexp    ${contents}    ${XEPA-02_Regex}
    log    ${XEPA-02-ID}
    ${ping_backup}    get regexp matches   ${contents}   ${1st_rgx}${XEPA-02-ID}${2nd_rgx}${0% packet loss}
    log     ${ping_backup}
    FOR    ${ping_backup-data}     IN    ${ping_backup}[0]
            log    ${ping_backup-data}
            should not contain    ${ping_backup-data}    ${Destination_Host_Unreachable}
            should not contain    ${ping_backup-data}    ${Something_is_wrong}
            should contain      ${ping_backup-data}    ${64byts}
    END


Verification of CIBR Version for CIBR-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${CIBR-01-ID}     should match regexp        ${contents}    ${1st_rgx}${CIBR}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${CIBR-01-ID}
    FOR    ${CIBR-1-ID}    IN    ${CIBR-01-ID}[0]
           FOR    ${CIBR-ID}    IN    ${CIBR-1-ID}[0:12]
              log    ${CIBR-ID}
           END
    END
    ${CIBR_ver}     should match regexp    ${contents}    ${1st_rgx}${CIBR-ID}${2nd_rgx}${CIBR_Copy_regex}
    log     ${CIBR_ver}
    ${ver}      Convert To String      ${CIBR_ver}
    log     ${ver}
    ${version}     get regexp matches    ${ver}    ${pre_regex}
    log     ${version}
    ${str_ver}     Convert To String     ${version}
    log     ${str_ver}
    ${num}     get regexp matches      ${str_ver}    ${get_number_regex}
    log     ${num}
    FOR    ${newnum}     IN      ${num}[0]
        IF    ${newnum} >= ${104}    CONTINUE
            log    ${newnum}
    END

Verification of CIBR Version for CIBR-02
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${CIBR-02-ID}     should match regexp        ${contents}    ${CIBR-02-Regex}
    log    ${CIBR-02-ID}
    ${CIBR_ver}     should match regexp    ${contents}    ${1st_rgx}${CIBR-02-ID}${2nd_rgx}${CIBR_Copy_regex}
    log     ${CIBR_ver}
    ${ver}      Convert To String      ${CIBR_ver}
    log     ${ver}
    ${version}     get regexp matches    ${ver}    ${pre_regex}
    log     ${version}
    ${str_ver}     Convert To String     ${version}
    log     ${str_ver}
    ${num}     get regexp matches      ${str_ver}    ${get_number_regex}
    log     ${num}
    FOR    ${newnum}     IN      ${num}[0]
        IF    ${newnum} >= ${104}    CONTINUE
            log    ${newnum}
    END

Establish Verification PROD server status for PROD-01
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${PROD-01-ID}     should match regexp        ${contents}    ${1st_rgx}${PROD}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${PROD-01-ID}
    FOR    ${PROD-1-ID}    IN    ${PROD-01-ID}[0]
           FOR    ${PROD-ID}    IN    ${PROD-1-ID}[0:17]
              log    ${PROD-ID}
           END
    END
    ${pacemaker-service-status-01}     should match regexp    ${contents}       ${1st_rgx}${PROD-ID}${2nd_rgx}${pacemaker-service}${2nd_rgx}${running}${2nd_rgx}${PROD-02-ID}${2nd_rgx}${running}
    log    ${pacemaker-service-status-01}
    FOR    ${pacemaker-service-data}    IN     ${pacemaker-service-status-01}[0]
           log    ${pacemaker-service-data}
           should match regexp    ${pacemaker-service-data}     ${1st_rgx}${pacemaker-service}${2nd_rgx}${running}
           should not contain     ${pacemaker-service-data}     ${WCS}
        END
    ${squid-service-status-01}       should match regexp    ${contents}       ${1st_rgx}${PROD-ID}${2nd_rgx}${squid-service}${2nd_rgx}${running}${2nd_rgx}${PROD-02-ID}${2nd_rgx}${running}
    log    ${squid-service-status-01}
    FOR    ${squid-service-data}    IN     ${squid-service-status-01}[0]
           log    ${squid-service-data}
           should match regexp    ${squid-service-data}     ${1st_rgx}${squid-service}${2nd_rgx}${running}
           should not contain     ${squid-service-data}     ${WCS}
    END

Establish Verification PROD server status for PROD-02
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${PROD-02-ID}   should match regexp     ${contents}     ${prod-02}
    log    ${PROD-02-ID}
    ${pacemaker-service-status-02}     should match regexp    ${contents}       ${1st_rgx}${PROD-02-ID}${2nd_rgx}${pacemaker-service}${2nd_rgx}${running}
    log    ${pacemaker-service-status-02}
    FOR    ${pacemaker-service-data}    IN     ${pacemaker-service-status-02}[0]
           log    ${pacemaker-service-data}
           should match regexp    ${pacemaker-service-data}     ${1st_rgx}${pacemaker-service}${2nd_rgx}${running}
           should not contain     ${pacemaker-service-data}     ${WCS}
    END
    ${squid-service-status-02}       should match regexp    ${contents}       ${1st_rgx}${PROD-02-ID}${2nd_rgx}${squid-service}${2nd_rgx}${running}
    log    ${squid-service-status-02}
    FOR    ${squid-service-data}    IN     ${squid-service-status-02}[0]
           log    ${squid-service-data}
           should match regexp    ${squid-service-data}     ${1st_rgx}${squid-service}${2nd_rgx}${running}
           should not contain     ${squid-service-data}     ${WCS}
    END

Healthcheck All Keywords
    run keyword and continue on failure    Establish Verification of Master AAA
    run keyword and continue on failure    Establish Verification of Bacukup AAA
    run keyword and continue on failure    Establish Verification of Zvelo Server services for WCS-01
    run keyword and continue on failure    Establish Verification of Zvelo Downloader Services for WCS-01
    run keyword and continue on failure    Establish Verification of Zvelo Updater Services for WCS-01
    run keyword and continue on failure    Establish Verification of Zvelo Server services for WCS-02
    run keyword and continue on failure    Establish Verification of Zvelo Downloader services for WCS-02
    run keyword and continue on failure    Establish Verification of Zvelo Updater services for WCS-02
    run keyword and continue on failure    Establish Verification of Online status of COL-01
    run keyword and continue on failure    Establish Verification of Collector Service for COL-01 for pacemaker status
    run keyword and continue on failure    Establish Verification of Collector Service for COL-01 for corosync status
    run keyword and continue on failure    Establish Verification of Collector Service for COL-01 for pcsd status
    run keyword and continue on failure    Establish Verification of Online status of COL-02
    run keyword and continue on failure    Establish Verification of Collector Service for COL-02 for pacemaker Status
    run keyword and continue on failure    Establish Verification of Collector Service for COL-02 for corosync Status
    run keyword and continue on failure    Establish Verification of Collector Service for COL-02 for pcsd Status
    run keyword and continue on failure    Establish Verification Connectivity Between CORE and XEPA-01
    run keyword and continue on failure    Establish Verification Connectivity Between CORE and XEPA-02
    run keyword and continue on failure    Verification of CIBR Version for CIBR-01
    run keyword and continue on failure    Verification of CIBR Version for CIBR-02
    run keyword and continue on failure    Establish Verification PROD server status for PROD-01
    run keyword and continue on failure    Establish Verification PROD server status for PROD-02

Check BGP Summary for ABR1
    Establish Connection for Jump Server through Routing
    write    ssh -o "StrictHostKeyChecking no" ${master_username}@${ABR_LON01}
    Read Until    password:
    Write    ${Pwd}
    ${output2}=    Read Until   ~#
    log    ${output2}
    Check IP BGP Summary for ABR and RSX Node


Check IP BGP Summary for ABR and RSX Node
    wait until keyword succeeds    2min    5sec    write    ${vtysh_cmd}
    ${route1}    read    delay=10s
    write    ${bgp_cmd}
    ${route}    read    delay=30s
    log    ${route}
    ${new_str}   remove string using regexp    ${route}    ${cmd_data_regex}
    log    ${new_str}
    ${new_str1}   remove string using regexp   ${new_str}    ${cmd_data_total_regex}
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
    @{up_down}     get column value    ${EXECDIR}/${dff_dir_bgp}/${BGP_check_final}      ${up_dowm_column}
    log    ${up_down}
    @{ALLOWED}=   create list    Idle    Connect    Active    OpenSent    OpenConfirm
    FOR    ${item}    IN    @{row}
           log    ${item}
           ${PAGE}=  set variable  ${item}
           IF  $PAGE not in $ALLOWED
                           Log    '${PAGE}' contains Valid Value
           ELSE
                           run keyword and continue on failure    fail  '${PAGE}' contains Invalid Value
           END
    END
    FOR    ${value}      IN    @{up_down}
        log    ${value}
        IF    '${value}' == 'never'
            run keyword and continue on failure    fail
        END
    END

Check BGP Summary For All ABR's
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${ABRS_json_path}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["ABR"]}
    Log  ${properties}
    @{Failed_ABRs}=    Create List
    @{Passed_ABRs}=    Create List
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Check BGP Summary for different ABR    ${sub dict}[ip]   ${sub dict}[username]   ${sub dict}[password]
         log    ${status}
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
    run keyword and continue on failure    Fail    Log Many    Failed ABRS: ${Failed_ABRs}    Failed ABRS Count: ${fail}    Please Check BGP Summary in logs for ${Failed_ABRs}

Check BGP Summary for different ABR
    [Arguments]    ${ip}    ${username}    ${password}
    Establish Connection for Jump Server through TS-LAX-root for AMB-LAX
    write    ssh -o "StrictHostKeyChecking no" ${username}@${ip}
    sleep    20s
    wait until keyword succeeds    2min    5sec    Read until    password:
    Write    ${password}
    sleep    20s
    ${output2}=    Read Until   ~#
    log    ${output2}
    Check IP BGP Summary for ABR and RSX Node

Establish Connection on LAX Server for test
    ${password}=    Get Decrypted Text    ${AMB_Lax_Password}
    log    ${password}
    Establish Connection for Jump Server through Routing
    write    ${SSH_NoCLient_Ask} ${master_username}@${AMB_LAX01}
    Read Until    password:
    Write    ${password}
    ${out4}=    Read Until   ~#

Executing Radius command and get IP of Client assigned by CORE
    ${password}=    Get Decrypted Text    ${PASSWORD_Ymq}
    log    ${password}
    Establish Connection on LAX Server for test
    write     ${SSH_NoCLient_Ask} ${USERNAME1}@${AAA_YMQ_Simulator}
    ${simulator}    read    delay=10s
    IF    $match in $simulator
        Write   ${Radius_Message_directory}
    ELSE
        sleep    5s
        should contain     ${simulator}    password:
        write    ${password}
        read Until   ~#
        Write   ${Radius_Message_directory}
    END
    Write   pwd
    ${out1}=    Read Until   ${Verify_testClient}
    log     ${out1}
    write   ${Radius_Message_execution}
    ${radius}   read    delay=100s
    log    ${radius}
    should contain  ${radius}   PASS
    ${lines}=   should match regexp      ${radius}    ${Radiusregex}
    ${lines1}=  should match regexp     ${lines}     ${IPregex}
    log    ${lines}
    log    ${lines1}
    [Return]    ${lines1}

Establish Radius Command only
    ${password}=    Get Decrypted Text    ${PASSWORD_Ymq}
    log    ${password}
    Establish Connection on LAX Server for test
    write     ssh ${USERNAME1}@${AAA_LAX_Simulator}
    ${simulator}    read    delay=10s
    IF    $match in $simulator
        Write   ${Radius_Message_directory}
    ELSE
        sleep    5s
        should contain     ${simulator}    password:
        write    ${password}
        read Until   ~#
        Write   ${Radius_Message_directory}
    END
    Write   pwd
    ${out1}=    Read Until   ${Verify_testClient}
    log     ${out1}
    write   ${Radius_Message_execution}
    ${radius}   read    delay=100s
    log    ${radius}
    should contain  ${radius}   PASS

HealthCheck of All sites
    ${users_json_path}=    set variable    ${EXECDIR}/${Common_Path}/${DE_Sites_path}
    ${the file as string}=    operatingsystem.get file    ${users_json_path}
    ${parsed}=    Evaluate  json.loads("""${the file as string}""")    json
    ${properties}=  Set Variable  ${parsed["DE Sites"]}
    Log  ${properties}
    @{Failed_DE_Sites}=    Create List
    @{Passed_DE_Sites}=    Create List
    Set Test Variable    ${fail}    ${0}
    Set Test Variable    ${pass}    ${0}
    FOR    ${key}    IN    @{properties}
         ${sub dict}=    Get From Dictionary    ${properties}    ${key}
         Log  ${sub dict}
         ${status}=    run keyword and return status    Health Check All Parameters    ${sub dict}[name]
         log    ${status}
         run keyword and continue on failure    Run keyword if    ${status} == ${False}    fail    '${sub dict}[name]' healthcheck report is not fine. Please Check 'HealthCheck All Parameters' Keywords for Detailed Investigation
         ${passed}    set variable if    ${status} == ${True}    ${True}
         log    ${passed}
         ${failed}    set variable if    ${status} == ${False}   ${False}
         log    ${failed}
         IF    ${failed} == ${False}
               ${fail}=    Evaluate    ${fail} + 1
               log    ${fail}
               append to list    ${Failed_DE_Sites}    ${key}
         ELSE IF    ${passed}
               ${pass}=    Evaluate    ${pass} + 1
               log    ${pass}
               append to list    ${Passed_DE_Sites}    ${key}
         Log  ${key} is successfully Checked.
         END
    END
    Log Many    Passed DE Sites: ${Passed_DE_Sites}    Passed DE Sites Count: ${pass}
    run keyword and continue on failure    Fail    Log Many    Failed DE Sites: ${Failed_DE_Sites}   Failed DE Sites Count: ${fail}    Please Check Health Check Report Summary in logs for ${Failed_DE_Sites}

Health Check Establish Verification Connectivity Between CORE and XEPA-01 for respective DE Site
    [Arguments]    ${site_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${XEPA-01-ID}     should match regexp        ${contents}    ${1st_rgx}${XEPA}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${XEPA-01-ID}
    FOR    ${XEPA-1-ID}    IN    ${XEPA-01-ID}[0]
           FOR    ${XEPA-ID}    IN    ${XEPA-1-ID}[0:12]
              log    ${XEPA-ID}
           END
    END
    ${ping_master}    get regexp matches   ${contents}   ${1st_rgx}${XEPA-ID}${2nd_rgx}${0% packet loss}
    log     ${ping_master}
    FOR    ${ping_master-data}     IN    ${ping_master}[0]
            log    ${ping_master-data}
            should not contain    ${ping_master-data}    ${Destination_Host_Unreachable}
            should not contain    ${ping_master-data}    ${Something_is_wrong}
            should contain      ${ping_master-data}     ${64byts}
    END

Establish Connection for Jump Server through TS-LAX-root for AMB-LAX Test
    ${password}=    Get Decrypted Text    ${AMB_Lax_Password}
    log    ${password}
    Establish Connection and Log In for TX-LAX-Root
    write    ${SSH_NoCLient_Ask} ${master_username}@${AMB_LAX01}
    Read Until    password:
    Write    ${password}
    ${output}=    Read Until   ~#
    log     ${output}
    Write    pwd
    ${output}=    Read Until   ~#
    log     ${output}
    SSHLibrary.directory should exist    /root/rahulb
    sshlibrary.get file    root/rahulb/beanshells/logs/    ${EXECDIR}/${Common_Path}
    ${curdir}

Execute Health Check for the DE Site
    [Arguments]    ${site_name}
    ${inp}    write    ${Health_check_directory}
    Write  ${Present_working_directory}
    ${output2}=    Read Until   ${Verify_Beanshells}
    log    ${inp}
    log     ${output2}
    write    ${Health_check_execution} ${site_name}
    ${output3}    read      delay=600sec
    log    ${output3}
    sleep    10s
    Health Check Script Verification    ${output3}

Establish Verification of Zvelo Server services for WCS-01_ID
    [Arguments]    ${s_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${s_name}
    log    ${Upr_site_name}
    ${WCS-01-ID}     should match regexp        ${contents}    ${1st_rgx}${WCS}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${WCS-01-ID}
    FOR    ${WCS-1-ID}    IN    ${WCS-01-ID}[0]
            FOR    ${WCS-ID}    IN    ${WCS-1-ID}[0:12]
            log    ${WCS-ID}
            END
    END
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-01-zvelo-server}     should match regexp    ${contents}    ${1st_rgx}${WCS-ID}${2nd_rgx}${zvelo-server}${2nd_rgx}${running}
    log     ${WCS-01-zvelo-server}
    FOR    ${WCS-01-zvelo-server-data}     IN    ${WCS-01-zvelo-server}[0]
        log    ${WCS-01-zvelo-server-data}
        should not contain    ${WCS-01-zvelo-server-data}      ${failed}
    END

Establish Verification of Zvelo Downloader Services for WCS-01_ID
    [Arguments]    ${s_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${s_name}
    log    ${Upr_site_name}
    ${WCS-01-ID}     should match regexp        ${contents}    ${1st_rgx}${WCS}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${WCS-01-ID}
    FOR    ${WCS-1-ID}    IN    ${WCS-01-ID}[0]
            FOR    ${WCS-ID}    IN    ${WCS-1-ID}[0:12]
            log    ${WCS-ID}
            END
    END
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-01-zvelo-downloader}     should match regexp      ${contents}     ${1st_rgx}${WCS-ID}${2nd_rgx}${zvelo-downloader}${2nd_rgx}${dead}
    log     ${WCS-01-zvelo-downloader}
    FOR    ${WCS-01-zvelo-downloader-data}     IN    ${WCS-01-zvelo-downloader}[0]
        log    ${WCS-01-zvelo-downloader-data}
        should not contain    ${WCS-01-zvelo-downloader-data}      ${failed}
    END

Establish Verification of Zvelo Updater Services for WCS-01_ID
    [Arguments]    ${s_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${s_name}
    log    ${Upr_site_name}
    ${WCS-01-ID}     should match regexp        ${contents}    ${1st_rgx}${WCS}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${WCS-01-ID}
    FOR    ${WCS-1-ID}    IN    ${WCS-01-ID}[0]
            FOR    ${WCS-ID}    IN    ${WCS-1-ID}[0:12]
            log    ${WCS-ID}
            END
    END
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${WCS-01-zvelo-updater}        should match regexp      ${contents}     ${1st_rgx}${WCS-ID}${2nd_rgx}${zvelo-updater}${2nd_rgx}${dead}
    FOR    ${WCS-01-zvelo-updater-data}     IN    ${WCS-01-zvelo-updater}[0]
        log     ${WCS-01-zvelo-updater-data}
        should not contain    ${WCS-01-zvelo-updater-data}      ${failed}
    END

Establish Verification of Online status of Collector-01
    [Arguments]    ${site_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${COL-01-ID}     should match regexp        ${contents}    ${1st_rgx}${COL}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${COL-01-ID}
    FOR    ${COL-1-ID}    IN    ${COL-01-ID}[0]
           FOR    ${COL-ID}    IN    ${COL-1-ID}[0:12]
              log    ${COL-ID}
           END
    END
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL01-Online}     should match regexp      ${contents}     ${1st_rgx}${PCSD Status}${2nd_rgx}${COL-ID}${cluster}${2nd_rgx}${Online}
    log     ${COL01-Online}
    FOR    ${COL-online}    IN    ${COL01-Online}[0]
            log    ${COL-online}
            should match regexp    ${COL-online}    ${1st_rgx}${PCSD Status}${2nd_rgx}${COL-ID}${cluster}: ${ONLINE}
    END

Establish Verification of Collector Service for Collector-01 for pacemaker status
    [Arguments]    ${site_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${COL-01-ID}     should match regexp        ${contents}    ${1st_rgx}${COL}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${COL-01-ID}
    FOR    ${COL-1-ID}    IN    ${COL-01-ID}[0]
           FOR    ${COL-ID}    IN    ${COL-1-ID}[0:12]
              log    ${COL-ID}
           END
    END
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL01-pacemaker}     should match regexp      ${contents}     ${1st_rgx}${COL-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${pacemaker}${2nd_rgx}${active/enabled}
    log     ${COL01-pacemaker}
    FOR    ${COL01-pacemaker-data}     IN    ${COL01-pacemaker}[0]
           log    ${COL01-pacemaker-data}
           should contain    ${COL01-pacemaker-data}    ${pacemaker}: ${active/enabled}
    END

Establish Verification of Collector Service for Collector-01 for corosync status
    [Arguments]    ${site_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${COL-01-ID}     should match regexp        ${contents}    ${1st_rgx}${COL}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${COL-01-ID}
    FOR    ${COL-1-ID}    IN    ${COL-01-ID}[0]
           FOR    ${COL-ID}    IN    ${COL-1-ID}[0:12]
              log    ${COL-ID}
           END
    END
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL01-corosync}     should match regexp      ${contents}     ${1st_rgx}${COL-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${corosync}${2nd_rgx}${active/enabled}
    log     ${COL01-corosync}
    FOR    ${COL01-corosync-data}     IN    ${COL01-corosync}[0]
           log    ${COL01-corosync-data}
           should contain    ${COL01-corosync-data}    ${corosync}: ${active/enabled}
    END

Establish Verification of Collector Service for Collector-01 for pcsd status
    [Arguments]    ${site_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${COL-01-ID}     should match regexp        ${contents}    ${1st_rgx}${COL}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${COL-01-ID}
    FOR    ${COL-1-ID}    IN    ${COL-01-ID}[0]
           FOR    ${COL-ID}    IN    ${COL-1-ID}[0:12]
              log    ${COL-ID}
           END
    END
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${COL01-pcsd}     should match regexp      ${contents}     ${1st_rgx}${COL-ID}${2nd_rgx}${Daemon Status}${2nd_rgx}${pcsd}${2nd_rgx}${active/enabled}
    log     ${COL01-pcsd}
    FOR    ${COL01-pcsd-data}     IN    ${COL01-pcsd}[0]
           log    ${COL01-pcsd-data}
           should contain    ${COL01-pcsd-data}    ${pcsd}: ${active/enabled}
    END

Verification of CIBR Version CIBR-01 for Respective DE site
    [Arguments]    ${site_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${CIBR-01-ID}     should match regexp        ${contents}    ${1st_rgx}${CIBR}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${CIBR-01-ID}
    FOR    ${CIBR-1-ID}    IN    ${CIBR-01-ID}[0]
           FOR    ${CIBR-ID}    IN    ${CIBR-1-ID}[0:12]
              log    ${CIBR-ID}
           END
    END
    ${CIBR_ver}     should match regexp    ${contents}    ${1st_rgx}${CIBR-ID}${2nd_rgx}${CIBR_Copy_regex}
    log     ${CIBR_ver}
    ${ver}      Convert To String      ${CIBR_ver}
    log     ${ver}
    ${version}     get regexp matches    ${ver}    ${pre_regex}
    log     ${version}
    ${str_ver}     Convert To String     ${version}
    log     ${str_ver}
    ${num}     get regexp matches      ${str_ver}    ${get_number_regex}
    log     ${num}
    FOR    ${newnum}     IN      ${num}[0]
        IF    ${newnum} >= ${104}    CONTINUE
            log    ${newnum}
    END

Establish Verification PROD server status PROD-01 for respective DE Site
    [Arguments]    ${site_name}
    ${contents}=   OperatingSystem.get file     ${EXECDIR}/${dff_dir}/${Health_check}
    ${Upr_site_name}    convert to upper case    ${site_name}
    log    ${Upr_site_name}
    ${PROD-01-ID}     should match regexp        ${contents}    ${1st_rgx}${PROD}${2nd_rgx}${Upr_site_name}${2nd_rgx}${01}${2nd_rgx}${01}
    log    ${PROD-01-ID}
    FOR    ${PROD-1-ID}    IN    ${PROD-01-ID}[0]
           FOR    ${PROD-ID}    IN    ${PROD-1-ID}[0:17]
              log    ${PROD-ID}
           END
    END
    ${PROD-02-ID}   should match regexp     ${contents}     ${prod-02}
    log    ${PROD-02-ID}
    ${pacemaker-service-status-01}     should match regexp    ${contents}       ${1st_rgx}${PROD-ID}${2nd_rgx}${pacemaker-service}${2nd_rgx}${running}${2nd_rgx}${PROD-02-ID}${2nd_rgx}${running}
    log    ${pacemaker-service-status-01}
    FOR    ${pacemaker-service-data}    IN     ${pacemaker-service-status-01}[0]
           log    ${pacemaker-service-data}
           should match regexp    ${pacemaker-service-data}     ${1st_rgx}${pacemaker-service}${2nd_rgx}${running}
           should not contain     ${pacemaker-service-data}     ${WCS}
        END
    ${squid-service-status-01}       should match regexp    ${contents}       ${1st_rgx}${PROD-ID}${2nd_rgx}${squid-service}${2nd_rgx}${running}${2nd_rgx}${PROD-02-ID}${2nd_rgx}${running}
    log    ${squid-service-status-01}
    FOR    ${squid-service-data}    IN     ${squid-service-status-01}[0]
           log    ${squid-service-data}
           should match regexp    ${squid-service-data}     ${1st_rgx}${squid-service}${2nd_rgx}${running}
           should not contain     ${squid-service-data}     ${WCS}
    END

Health Check All Parameters
    [Arguments]    ${site_name}
    @{DE_sites_status}=    Create List
    ${status_healthcheck}=    run keyword and return status    Execute Health Check for the DE Site    ${site_name}
    log    ${status_healthcheck}
    append to list    ${DE_sites_status}    ${status_healthcheck}
    run keyword and continue on failure    Run keyword if    ${status_healthcheck} == ${False}    fail    '${site_name}' healthcheck report didn't generate properly.
    ${status_Master}=    run keyword and return status    Establish Verification of Master AAA
    log    ${status_Master}
    append to list    ${DE_sites_status}    ${status_Master}
    run keyword and continue on failure    Run keyword if    ${status_Master} == ${False}    fail    Verification of Master AAA Failed.
    ${status_Backup}=    run keyword and return status    Establish Verification of Bacukup AAA
    log    ${status_Backup}
    append to list    ${DE_sites_status}    ${status_Backup}
    run keyword and continue on failure    Run keyword if    ${status_Backup} == ${False}    fail    Verification of Bacukup AAA Failed.
    ${status_Zvelo_server}=    run keyword and return status    Establish Verification of Zvelo Server services for WCS-01_ID    ${site_name}
    log    ${status_Zvelo_server}
    append to list    ${DE_sites_status}    ${status_Zvelo_server}
    run keyword and continue on failure    Run keyword if    ${status_Zvelo_server} == ${False}    fail    Verification of Zvelo Server services for WCS-01 Failed.
    ${status_Downloader}=    run keyword and return status    Establish Verification of Zvelo Downloader Services for WCS-01_ID    ${site_name}
    log    ${status_Downloader}
    append to list    ${DE_sites_status}    ${status_Downloader}
    run keyword and continue on failure    Run keyword if    ${status_Downloader} == ${False}    fail    Verification of Zvelo Server services for WCS-01 Failed.
    ${status_Updater}=    run keyword and return status    Establish Verification of Zvelo Updater Services for WCS-01_ID    ${site_name}
    log    ${status_Updater}
    append to list    ${DE_sites_status}    ${status_Updater}
    run keyword and continue on failure    Run keyword if    ${status_Updater} == ${False}    fail    Verification of Zvelo Server services for WCS-01 Failed.
    ${status_Zvelo_server02}=    run keyword and return status    Establish Verification of Zvelo Server services for WCS-02
    log    ${status_Zvelo_server02}
    append to list    ${DE_sites_status}    ${status_Zvelo_server02}
    run keyword and continue on failure    Run keyword if    ${status_Zvelo_server02} == ${False}    fail    Verification of Zvelo Server services for WCS-02 Failed.
    ${status_Downloader02}=    run keyword and return status    Establish Verification of Zvelo Downloader Services for WCS-02
    log    ${status_Downloader02}
    append to list    ${DE_sites_status}    ${status_Downloader02}
    run keyword and continue on failure    Run keyword if    ${status_Downloader02} == ${False}    fail    Verification of Zvelo Server services for WCS-02 Failed.
    ${status_Updater02}=    run keyword and return status    Establish Verification of Zvelo Updater Services for WCS-02
    log    ${status_Updater02}
    append to list    ${DE_sites_status}    ${status_Updater02}
    run keyword and continue on failure    Run keyword if    ${status_Updater02} == ${False}    fail    Verification of Zvelo Server services for WCS-02 Failed.
    ${status_collector}=    run keyword and return status    Establish Verification of Online status of Collector-01    ${site_name}
    log    ${status_collector}
    append to list    ${DE_sites_status}    ${status_collector}
    run keyword and continue on failure    Run keyword if    ${status_collector} == ${False}    fail    Verification of Online status of Collector-01 Failed.
    ${status_pacemaker}=    run keyword and return status    Establish Verification of Collector Service for Collector-01 for pacemaker status   ${site_name}
    log    ${status_pacemaker}
    append to list    ${DE_sites_status}    ${status_pacemaker}
    run keyword and continue on failure    Run keyword if    ${status_pacemaker} == ${False}    fail    Verification of pacemaker status of Collector-01 Failed.
    ${status_corosync}=    run keyword and return status    Establish Verification of Collector Service for Collector-01 for corosync status    ${site_name}
    log    ${status_corosync}
    append to list    ${DE_sites_status}    ${status_corosync}
    run keyword and continue on failure    Run keyword if    ${status_corosync} == ${False}    fail    Verification of corosync status of Collector-01 Failed.
    ${status_pcsd}=    run keyword and return status    Establish Verification of Collector Service for Collector-01 for pcsd status    ${site_name}
    log    ${status_pcsd}
    append to list    ${DE_sites_status}    ${status_pcsd}
    run keyword and continue on failure    Run keyword if    ${status_Zvelo_server} == ${False}    fail    Verification of pcsd status of Collector-01 Failed.
    ${status_collector02}=    run keyword and return status    Establish Verification of Online status of COL-02
    log    ${status_collector02}
    append to list    ${DE_sites_status}    ${status_collector02}
    run keyword and continue on failure    Run keyword if    ${status_collector02} == ${False}    fail    Verification of Online status of COL-02 Failed.
    ${status_pacemaker02}=    run keyword and return status    Establish Verification of Collector Service for COL-02 for pacemaker Status
    log    ${status_pacemaker02}
    append to list    ${DE_sites_status}    ${status_pacemaker02}
    run keyword and continue on failure    Run keyword if    ${status_pacemaker02} == ${False}    fail    Verification of Collector Service for COL-02 for pacemaker Status Failed.
    ${status_corosync02}=    run keyword and return status    Establish Verification of Collector Service for COL-02 for corosync Status
    log    ${status_corosync02}
    append to list    ${DE_sites_status}    ${status_corosync02}
    run keyword and continue on failure    Run keyword if    ${status_corosync02} == ${False}    fail    Verification of Collector Service for COL-02 for corosync Status Failed.
    ${status_pcsd02}=    run keyword and return status    Establish Verification of Collector Service for COL-02 for pcsd Status
    log    ${status_pcsd02}
    append to list    ${DE_sites_status}    ${status_pcsd02}
    run keyword and continue on failure    Run keyword if    ${status_pcsd02} == ${False}    fail    Verification of Collector Service for COL-02 for pcsd Status Failed.
    ${status_XEPA01}=    run keyword and return status    Health Check Establish Verification Connectivity Between CORE and XEPA-01 for respective DE Site    ${site_name}
    log    ${status_XEPA01}
    append to list    ${DE_sites_status}    ${status_XEPA01}
    run keyword and continue on failure    Run keyword if    ${status_XEPA01} == ${False}    fail    Verification of connectivity Between CORE and XEPA-01 Failed.
    ${status_XEPA02}=    run keyword and return status    Establish Verification Connectivity Between CORE and XEPA-02
    log    ${status_XEPA02}
    append to list    ${DE_sites_status}    ${status_XEPA02}
    run keyword and continue on failure    Run keyword if    ${status_XEPA02} == ${False}    fail    Verification of Connectivity Between CORE and XEPA-02 Failed.
    ${status_CIBR-01}=    run keyword and return status    Verification of CIBR Version CIBR-01 for Respective DE site    ${site_name}
    log    ${status_CIBR-01}
    append to list    ${DE_sites_status}    ${status_CIBR-01}
    run keyword and continue on failure    Run keyword if    ${status_CIBR-01} == ${False}    fail    Verification of CIBR Version CIBR-01 for Respective DE site Failed.
    ${status_CIBR-02}=    run keyword and return status    Verification of CIBR Version for CIBR-02
    log    ${status_CIBR-02}
    append to list    ${DE_sites_status}    ${status_CIBR-02}
    run keyword and continue on failure    Run keyword if    ${status_CIBR-02} == ${False}    fail    Verification of CIBR Version for CIBR-02 Failed.
    ${status_PROD-01}=    run keyword and return status    Establish Verification PROD server status PROD-01 for respective DE Site    ${site_name}
    log    ${status_PROD-01}
    append to list    ${DE_sites_status}    ${status_PROD-01}
    run keyword and continue on failure    Run keyword if    ${status_PROD-01} == ${False}    fail    Verification of PROD server status PROD-01 for respective DE Site Failed.
    ${status_PROD-02}=    run keyword and return status    Establish Verification PROD server status for PROD-02
    log    ${status_PROD-02}
    append to list    ${DE_sites_status}    ${status_PROD-02}
    run keyword and continue on failure    Run keyword if    ${status_PROD-02} == ${False}    fail    Verification of PROD server status for PROD-02 Failed.
    ${cnt}=  Get length    ${DE_sites_status}
    Log    ${cnt}
    Log    ${DE_sites_status}
    ${PAGE}=  set variable  ${False}
    IF  $PAGE in $DE_sites_status
         run keyword and continue on failure    fail  '${site_name}' health report is not fine, having Problems.Please Check detailed logs for further inspection.
    ELSE
         Log    '${site_name}' health check Report is Fine.There is no Problem with '${site_name}'
    END

Download Files from Server
    Run keyword and continue on failure    SSHLibrary.directory should exist    ${Pcap_logs_path}
    SSHLibrary.Get Directory   ${Pcap_logs_path}   ${EXECDIR}/${Pcap_Path}    scp=ALL    scp_preserve_times=True

Establish Connection TS-LAX-Root
    ${password}=    Get Decrypted Text    ${TS_LAX_Pass}
    log    ${password}
    ${output}     open connection
    ...     ${TX-LAX-Root}
    Log    ${output}
    ${Display}    login
    ...    ${master_username}
    ...    ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=1

Establish Connection AMB Server
    ${password}=    Get Decrypted Text    ${AMB_Lax_Password}
    log    ${password}
    ${output}     open connection
    ...     ${AMB_LAX01}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=2
    should contain   ${Display}    Last login

Establish Connection AMB Server EU
    ${password}=    Get Decrypted Text    ${AMB_Lax_Password}
    log    ${password}
    ${output}     open connection
    ...     ${AMB_LAX01}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=1
    should contain   ${Display}    Last login

Establish Connection AMB Server 12 EU
    ${password}=    Get Decrypted Text    ${AMB_Lax_Password}
    log    ${password}
    ${output}     open connection
    ...     ${AMB_LAX01_12}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=1
    should contain   ${Display}    Last login

Establish Connection and Log In to AMB LAX
    Establish Connection and Log In for Denv-NMS
    Establish Connection TS-LAX-Root
    Establish Connection AMB Server


Establish Connection and Log In to AMB LAX directly
    Establish Connection and Log In for Denv-NMS EU
    Establish Connection AMB Server EU

Establish Connection and Log In Singapore Server
    ${username}=    Get Decrypted Text    ${Chirag_nms_username}
    log    ${username}
    ${password}=    Get Decrypted Text    ${Chirag_nms_pass}
    log    ${password}
    ${output}    open connection
    ...     ${singapore_host}
    Log    ${output}
    ${Display}    login
    ...     ${username}
    ...     ${password}
    ...    delay = 120
    should contain   ${Display}    Last login

Establish Connection and Log In to AMB LAX 12 directly
    Establish Connection and Log In for Denv-NMS EU
    Establish Connection AMB Server 12 EU