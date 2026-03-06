*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
Library    String
Library    Collections
Resource   ../Variables/globalvariables.robot
Resource   ../Variables/pabotvariables.robot
Resource   ../Variables/HealthCheck_Variables.robot
Resource   ../Variables/Authentication_variables.robot
Library     CryptoLibrary    variable_decryption=False

*** Variables ***


*** Keywords ***

Establish Connection and Log In for Denv-NMS EU
    ${root_username}=    Get Decrypted Text    ${Chirag_nms_username}
    log    ${root_username}
    ${password}=    Get Decrypted Text    ${Chirag_nms_pass}
    log    ${password}
    ${output}     open connection
    ...     ${Host}
    Log    ${output}
    ${Display}    login
    ...     ${root_username}
    ...     ${password}
    ...    delay = 120
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

Establish Connection and Log In to AMB LAX pabot
    Establish Connection and Log In for Denv-NMS EU

Browse Test Through UE Simulator
    UE-Simulator Login
    write    ${UE_browse_traffic}
    sleep    1 minute 10 seconds
    ${curl_output}   read    delay=2s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}

Check Client latch on ABR-FRA08-05 or ABR-FRA08-06
    ${client_latch_ABR-FRA08-05}=    Execute Client latch Command on ABR-FRA08-05
    ${client_latch_ABR-FRA08-06}=    Execute Client latch Command on ABR-FRA08-06
    IF    ${client_latch_ABR-FRA08-05} != ''    # Check if ABR-FRA08-05 variable is not empty
          log   ${client_latch_ABR-FRA08-05}
    ELSE IF    ${client_latch_ABR-FRA08-06} != ''    # Check if ABR-FRA08-06 variable is not empty
          log   ${client_latch_ABR-FRA08-06}
    ELSE
          log   Both variables are empty
    END

Execute Client latch Command on ABR-FRA08-05
    Establish Connection and Log In to AMB LAX pabot
    ABR-FRA08-05-Login
    sleep    1 minute 10 seconds
    ${client}    Execute Command    ${client_latch_cmd}
    log    ${client}
    IF    '${client}'
          Log    Client is latched to ABR-FRA08-05
          ${parts}=     Split String    ${client}
          ${ip}=        Get From List    ${parts}    0
          log    ${ip}
    ELSE
          Log    Client is latched to ABR-FRA08-06
    END


Execute Client latch Command on ABR-FRA08-06
    Establish Connection and Log In to AMB LAX pabot
    ABR-FRA08-06-Login
    sleep    1 minute 10 seconds
    ${client}    Execute Command    ${client_latch_cmd}
    log    ${client}
    IF    '${client}'
          Log    Client is latched to ABR-FRA08-06
          ${parts}=     Split String    ${client}
          ${ip}=        Get From List    ${parts}    0
          log    ${ip}
    ELSE
          Log    Client is latched to ABR-FRA08-05
    END

Get Client Latch From ABR-FRA08-05 Or ABR-FRA08-06
    [Arguments]    ${wait_before_cmd}=70s    ${cmd}=ip route show table clients
    Log    Attempting client latch check on ABR-FRA08-05
    Establish Connection and Log In to AMB LAX pabot
    ABR-FRA08-05-Login
    Sleep    ${wait_before_cmd}
    ${raw5}=    Execute Command    ${cmd}    timeout=30s
    Log    Raw ABR-FRA08-05 latch output:\n${raw5}
    ${ip5}=    Parse Latch Output For IP    ${raw5}
    IF    '${ip5}' != ''
        Log    Client is latched to ABR-FRA08-05 with IP ${ip5}
        RETURN    ABR-FRA08-05    ${ip5}
    END

    Log    No valid IP from ABR-FRA08-05 latch output; proceeding to ABR-FRA08-06
    Establish Connection and Log In to AMB LAX pabot
    ABR-FRA08-06-Login
    Sleep    ${wait_before_cmd}
    ${raw6}=    Execute Command    ${cmd}    timeout=30s
    Log    Raw ABR-FRA08-06 latch output:\n${raw6}
    ${ip6}=    Parse Latch Output For IP    ${raw6}
    IF    '${ip6}' != ''
        Log    Client is latched to ABR-FRA08-06 with IP ${ip6}
        RETURN    ABR-FRA08-06    ${ip6}
    END

    Fail    Client is not latched to ABR-FRA08-05 or ABR-FRA08-06 (no IP found)

Parse Latch Output For IP
    [Arguments]    ${text}
    ${trim}=    Strip String    ${text}
    IF    '${trim}' == ''
        RETURN    ${EMPTY}
    END
    # Use only the first line (in case multiple lines)
    ${line0}=    Split To Lines    ${trim}
    ${line0}=    Get From List     ${line0}    0
    ${tokens}=   Split String      ${line0}
    ${candidate}=    Get From List    ${tokens}    0
    # Basic structural check
    ${octets}=   Split String      ${candidate}    .
    ${count}=    Get Length        ${octets}
    IF    ${count} != 4
        RETURN    ${EMPTY}
    END
    FOR    ${o}    IN    @{octets}
           ${ok}=    Run Keyword And Return Status    Should Match Regexp    ${o}    ^[0-9]{1,3}$
           IF    not ${ok}
                 RETURN    ${EMPTY}
           END

           ${val}=    Convert To Integer    ${o}
           IF    not (0 <= ${val} <= 255)
                RETURN    ${EMPTY}
           END
    END
    RETURN    ${candidate}

Establish Radius Command in AAA Simulator APN Healthcheck
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    40s
    Establish Connection and Log In to AMB LAX pabot
    write     ${SSH_NoCLient_Ask} ${root_username}@${APN-Health-Check-Simulator}
    ${simulator}    read    delay=10s
    IF    $match in $simulator
        Write   ${Radius_Message_directory}
    ELSE
        sleep    5s
        should contain     ${simulator}    password:
        write    ${password}
        Write   ${Radius_Message_directory}
    END
    Write   ${Present_working_directory}
    ${out1}=    Read Until   ${Verify_testClient}
    log     ${out1}
    write   ${Radius_APN_Health_Check_Message_execution}
    ${radius}   read    delay=120s
    log    ${radius}
    should contain  ${radius}   PASS
    ${lines}=   should match regexp      ${radius}    ${Radiusregex}
    ${lines1}=  should match regexp     ${lines}     ${IPregex}
    log    ${lines}
    log    ${lines1}
    set global variable    ${lines1}
    RETURN    ${lines1}

ABR-FRA08-05-Login
    ${password}=    Get Decrypted Text    ${fra08_password}
    log    ${password}
    ${output}     open connection
    ...     ${ABR5-FRA08-IP}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=1


ABR-FRA08-06-Login
    ${password}=    Get Decrypted Text    ${fra08_password}
    log    ${password}
    ${output}     open connection
    ...     ${ABR6-FRA08-IP}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=1

UE-Simulator Login
    Establish Connection and Log In to AMB LAX pabot
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${APN-Health-Check-Simulator}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 200
    ...    jumphost_index_or_alias=1
    write    ${UE_browse_traffic}
    ${output}=    Read    delay=120s
    Log    ${output}