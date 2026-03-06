*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
Library    String
Library    Collections
Resource   ../Variables/globalvariables.robot
Resource   ../Variables/pabotvariables.robot
Resource   ../Variables/HealthCheck_Variables.robot
Resource   ../Variables/Nanames_GI_Interface.robot
Resource   ../Variables/Authentication_variables.robot
Library     CryptoLibrary    variable_decryption=False

*** Variables ***
${SHARED_IP_FILE}    /tmp/subscriber_ip.txt
${IP_ADDED_FLAG}     /tmp/ip_added.flag
${PARALLEL_STATE_DIR}    /tmp/parallel_state
${IP_READY_FLAG}    ${PARALLEL_STATE_DIR}/ip_ready.flag
${BROWSE_DONE_FLAG}    ${PARALLEL_STATE_DIR}/browse_done.flag
${LATCH_DONE_FLAG}    ${PARALLEL_STATE_DIR}/latch_done.flag

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
    sleep    30 seconds
    ${raw}=    write    ${br_address}
    ${curl_output}   read    delay=2s
    log    ${curl_output}
    write    ${UE_traffic}
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
    ${password}=    Get Decrypted Text    ${DE_PASSWORD_PAR01}
    log    ${password}
    sleep    40s
    Establish Connection and Log In to AMB LAX pabot
    write     ${SSH_NoCLient_Ask} ${root_username}@${APN-Health-Check-PAR01}
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
    write   ${Radius_Execution}
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
    ${password}=    Get Decrypted Text    ${DE_PASSWORD_PAR01}
    log    ${password}
    ${output}     open connection
    ...     ${APN-Health-Check-PAR01}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 200
    ...    jumphost_index_or_alias=1
    write    ${UE_browse_traffic}
    ${output}=    Read    delay=120s
    Log    ${output}

Add Client IP to GI interface
    ${Subscriber_IP}=    Establish Radius Command in AAA Simulator APN Healthcheck
    log    ${Subscriber_IP}
    ${raw}=    Execute Command    ${IP_Add} ${Subscriber_IP} ${dev} ${A10_GI}      timeout=30s
    log    ${raw}

Delete Client IP from GI interface post test
    [Documentation]    Step 5 - Cleanup after parallel tests
    ${Subscriber_IP}=    OperatingSystem.Get File    ${SHARED_IP_FILE}
    ${Subscriber_IP}=    Strip String    ${Subscriber_IP}
    Log    Deleting Client IP: ${Subscriber_IP}
    UE-Simulator Login
    ${raw}=    write    ${IP_Del} ${Subscriber_IP}/32 ${dev} ${A10_GI}
    ${raw}=    write    ${br_address}
    ${curl_output}   read    delay=2s
    log    ${curl_output}
    OperatingSystem.Remove File    ${SHARED_IP_FILE}

Delete Client IP from GI interface post test execution
    [Documentation]    Step 5 - Cleanup after parallel tests
    ${file_exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${SHARED_IP_FILE}
    IF    ${file_exists}
        ${Subscriber_IP}=    OperatingSystem.Get File    ${SHARED_IP_FILE}
        ${Subscriber_IP}=    Strip String    ${Subscriber_IP}
        IF    '${Subscriber_IP}' != ''
            Log    Deleting Client IP: ${Subscriber_IP}
            UE-Simulator Login
            ${raw}=    Write    ${IP_Del} ${Subscriber_IP}/32 ${dev} ${A10_GI}
            ${raw}=    Write    ${br_address}
            ${curl_output}=    Read    delay=2s
            Log    ${curl_output}
            Should Contain    ${curl_output}    expected_success_message    msg=IP deletion may have failed
        ELSE
            Log    WARNING: Shared IP file is empty, skipping IP deletion    WARN
        END
        OperatingSystem.Remove File    ${SHARED_IP_FILE}
    ELSE
        Log    WARNING: Shared IP file not found, skipping cleanup    WARN
    END


Setup Radius And Add IP
    [Documentation]    Step 1 - Sequential setup before parallel tests
    ${Subscriber_IP}=    Establish Radius Command in AAA Simulator APN Healthcheck
    Log    Captured Subscriber IP: ${Subscriber_IP}
    OperatingSystem.Create File    ${SHARED_IP_FILE}    ${Subscriber_IP}
    UE-Simulator Login
    ${raw}=    write    ${IP_Add} ${Subscriber_IP}/32 ${dev} ${A10_GI}
    ${raw}=    write    ${br_address}
    ${curl_output}   read    delay=2s
    log    ${curl_output}
    should not contain    ${curl_output}    ${Unresolve_device}

Run Radius Command Parallel
    [Documentation]    Step 2 - Runs radius command in parallel with Browse and Latch
    ${Subscriber_IP}=    Establish Radius Command in AAA Simulator APN Healthcheck
    Log    Parallel Radius Subscriber IP: ${Subscriber_IP}

#Browse UE Parallel
#    [Documentation]    Step 3 - Browse UE in parallel
#    Browse Test Through UE Simulator

#Check Client Latch Parallel
#    [Documentation]    Step 4 - Check client latch in parallel
#    Get Client Latch From ABR-FRA08-05 Or ABR-FRA08-06


Execute Radius And Setup IP
    [Documentation]    Combines Radius Command and IP Addition. Sets Global Signals.
    Set Parallel Value For Key    IP_READY       FALSE
    Set Parallel Value For Key    BROWSE_DONE    FALSE
    Set Parallel Value For Key    LATCH_DONE     FALSE
    # 1. Establish Radius Command
    ${Subscriber_IP}=    Establish Radius Command in AAA Simulator APN Healthcheck
    Log    Captured Subscriber IP: ${Subscriber_IP}

    # 2. Add IP to Interface (Step 2)
    # Note: UE-Simulator Login is handled by Test Setup, or can be called here if needed specifically
    ${raw}=    write    ${IP_Add} ${Subscriber_IP}/32 ${dev} ${A10_GI}
    ${raw}=    write    ${br_address}
    ${curl_output}   read    delay=2s
    log    ${curl_output}

    # 3. Share IP and Signal Ready
    Set Parallel Value For Key    SUBSCRIBER_IP    ${Subscriber_IP}
    Set Parallel Value For Key    IP_READY    TRUE

Browse UE Parallel
    [Documentation]    Waits for IP setup, runs browse, signals completion.

    # Wait for Setup to complete (Poll every 5s, timeout 10min)
#    Wait Until Keyword Succeeds    10 min    5s    Check Parallel Key Is True    IP_READY

    # Get the IP (if needed for logging or logic)
    ${Subscriber_IP}=    Get Parallel Value For Key    SUBSCRIBER_IP
    Log    Starting Browse with IP: ${Subscriber_IP}
    sleep    30 seconds
    # Run the actual test
    Browse Test Through UE Simulator

    # Signal Completion
    Set Parallel Value For Key    BROWSE_DONE    TRUE

Check Client Latch Parallel
    [Documentation]    Waits for IP setup, checks latch, signals completion.

    # Wait for Setup
#    Wait Until Keyword Succeeds    10 min    5s    Check Parallel Key Is True    IP_READY

    # Run the actual test
    Get Client Latch From ABR-FRA08-05 Or ABR-FRA08-06

    # Signal Completion
    Set Parallel Value For Key    LATCH_DONE    TRUE

Cleanup Client IP Parallel
    [Documentation]    Waits for Browse and Latch to finish, then cleans up.

    # Wait for Parallel Tests
#    Wait Until Keyword Succeeds    10 min    5s    Check Parallel Key Is True    BROWSE_DONE
#    Wait Until Keyword Succeeds    10 min    5s    Check Parallel Key Is True    LATCH_DONE

    # Retrieve IP to delete
    ${Subscriber_IP}=    Get Parallel Value For Key    SUBSCRIBER_IP

    # Delete IP
    Log    Deleting Client IP: ${Subscriber_IP}
    UE-Simulator Login
    ${raw}=    write    ${IP_Del} ${Subscriber_IP}/32 ${dev} ${A10_GI}
    ${raw}=    write    ${br_address}
    ${curl_output}   read    delay=2s
    log    ${curl_output}

# Helper Keyword
#Check Parallel Key
#    [Arguments]    ${key}
#    ${value}=    Get Parallel Value For Key    ${key}
#    Should Be Equal    ${value}    TRUE

Set Parallel Value For Key
    [Arguments]    ${key}    ${value}
    Create Directory    ${PARALLEL_STATE_DIR}
    Create File    ${PARALLEL_STATE_DIR}/${key}.txt    ${value}
    Log    Set ${key}=${value}

Get Parallel Value For Key
    [Arguments]    ${key}
    ${file_path}=    Set Variable    ${PARALLEL_STATE_DIR}/${key}.txt
    ${value}=    OperatingSystem.Get File    ${file_path}
    ${value}=    Strip String    ${value}
    Log    Got ${key}=${value}
    RETURN    ${value}

Check Parallel Key
    [Arguments]    ${key}
    ${file_path}=    Set Variable    ${PARALLEL_STATE_DIR}/${key}.txt
    OperatingSystem.File Should Exist   ${file_path}     msg=${key} flag not found
    ${value}=    OperatingSystem.Get File    ${file_path}
    ${value}=    Strip String    ${value}
    Should Be Equal    ${value}    TRUE    msg=${key} is not TRUE

Execute Radius Traffic Only
    [Documentation]    Runs the Radius command again for traffic/healthcheck, but DOES NOT add IP.
    # 1. Wait for Setup to complete first (so we don't mess up the sequence)
#    Wait Until Keyword Succeeds    10 min    5s    Check Parallel Key Is True    IP_READY
    Sleep    30 seconds

    # 2. Run the command just for traffic generation
    Establish Radius Command in AAA Simulator APN Healthcheck


Check Parallel Key Is True
    [Arguments]    ${key}
    ${value}=    Get Parallel Value For Key    ${key}
    # This Log is crucial for debugging why it might be waiting forever
    Log    Checking key '${key}': found value '${value}'
    Should Be Equal    ${value}    TRUE    msg=Key '${key}' was '${value}', expected 'TRUE'