*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
Library    String
Library    Collections
Resource   ../Variables/globalvariables.robot
Resource   ../Variables/pabotglobalvariables.robot
Resource   ../Variables/Authentication_variables.robot
Library    ../CustomLibs/csv2.py
Library     CryptoLibrary    variable_decryption=False

*** Variables ***

*** Keywords ***

Establish Connection and Log In for Denv-NMS pabot
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

Establish Connection TS-LAX-Root pabot
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

Establish Connection AMB Server pabot
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
#    should contain   ${Display}    Last login


Establish Connection and Log In to AMB LAX pabot
    Establish Connection and Log In for Denv-NMS pabot
    Establish Connection TS-LAX-Root pabot
    Establish Connection AMB Server pabot

AAA-Simulator Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${AAA-Simulator}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

UE-Simulator Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${UE-Simulator}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

ABR-1 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${ABR-01}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

ABR-2 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${ABR-02}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

ABR-3 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${ABR-03}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

ABR-4 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${ABR-04}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

ABR-5 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${ABR-05}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

ABR-6 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${ABR-06}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

ABR-7 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${ABR-07}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

ABR-8 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${ABR-08}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3


RSX-1 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${RSX-01}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

RSX-2 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${RSX-02}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

RSX-3 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${RSX-03}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

RSX-4 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${RSX-04}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

RSX-5 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${RSX-05}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

RSX-6 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${RSX-06}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

RSX-7 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${RSX-07}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

RSX-8 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${RSX-08}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

AAA-1 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${AAA-01}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

AAA-2 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${AAA-02}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

XEPA-1 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${XEPA-01}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

XEPA-2 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${XEPA-02}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

WCS-1 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${WCS-01}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3

WCS-2 Login
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${output}     open connection
    ...     ${WCS-02}
    Log    ${output}
    ${Display}    login
    ...     ${master_username}
    ...     ${password}
    ...    delay = 120
    ...    jumphost_index_or_alias=3


Establish Radius Command only for pabot
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    40s
    Establish Connection and Log In to AMB LAX pabot
    write     ${SSH_NoCLient_Ask} ${USERNAME1}@${AAA-Simulator}
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
    write   ${Radius_Message_execution}
    ${radius}   read    delay=80s
    log    ${radius}
    should contain  ${radius}   PASS

Establish Connection and Log In for ABR1
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-1 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    write    ${taillab_cmd}
    ${tail}    read    delay=10s
    log    ${tail}
    should contain    ${client}    ${dev_lo}
    should contain    ${tail}    ${client_ip}

Establish Connection and Log In for ABR2
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-2 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    write    ${taillab_cmd}
    ${tail}    read    delay=10s
    log    ${tail}
    should contain    ${client}    ${dev_lo}
    should contain    ${tail}    ${client_ip}

Establish Connection and Log In for ABR3
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-3 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    write    ${taillab_cmd}
    ${tail}    read    delay=10s
    log    ${tail}
    should contain    ${client}    ${dev_lo}
    should contain    ${tail}    ${client_ip}

Establish Connection and Log In for ABR4
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-4 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    write    ${taillab_cmd}
    ${tail}    read    delay=10s
    log    ${tail}
    should contain    ${client}    ${dev_lo}
    should contain    ${tail}    ${client_ip}

Establish Connection and Log In for ABR5
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-5 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    write    ${taillab_cmd}
    ${tail}    read    delay=10s
    log    ${tail}
    should contain    ${client}    ${dev_lo}
    should contain    ${tail}    ${client_ip}

Establish Connection and Log In for ABR6
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-6 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    write    ${taillab_cmd}
    ${tail}    read    delay=10s
    log    ${tail}
    should contain    ${client}    ${dev_lo}
    should contain    ${tail}    ${client_ip}

Establish Connection and Log In for ABR7
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-7 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    write    ${taillab_cmd}
    ${tail}    read    delay=10s
    log    ${tail}
    should contain    ${client}    ${dev_lo}
    should contain    ${tail}    ${client_ip}

Establish Connection and Log In for ABR8
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-8 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    write    ${taillab_cmd}
    ${tail}    read    delay=10s
    log    ${tail}
    should contain    ${client}    ${dev_lo}
    should contain    ${tail}    ${client_ip}

Executing Radius command and get IP of Client assigned by CORE pabot
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    Establish Connection and Log In to AMB LAX pabot
    write     ${SSH_NoCLient_Ask} ${USERNAME1}@${AAA-Simulator}
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
    write   ${Radius_Message_execution}
    ${radius}   read    delay=3s
    log    ${radius}
#    should contain  ${radius}   PASS
    ${lines}=   should match regexp      ${radius}    ${Radiusregex}
    ${lines1}=  should match regexp     ${lines}     ${IPregex}
    log    ${lines}
    log    ${lines1}
    [Return]    ${lines1}


Establish UE Simulator Configuration pabot
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    ${3oct_IP}=    should match regexp    ${client_ip}    ${3oct_IPreg}
    log    ${3oct_IP}
    ${client_ip_253}=    set variable    ${3oct_IP}.253
    ${client_ip_254}=    set variable    ${3oct_IP}.254
    ${client_ip_/24}=    set variable    ${client_ip}/24
    log    ${client_ip_253}
    log    ${client_ip_254}
    Establish Connection and Log In to AMB LAX pabot
    write    ${SSH_NoCLient_Ask} ${USERNAME1}@${UE-Simulator}
    ${simulator}    read    delay=10s
    should contain    ${simulator}    password:
    write    ${password}
    sleep   3s
    read Until   ~#
    #Delete Existing Configuration
    write    ${Delete_cmd_1} ${client_ip_253} dev ${Int_Name}
    ${delete_1}    read
    log    ${delete_1}
    sleep    5s
    write    ${Delete_cmd_1} ${client_ip_254} dev ${Int_Name}
    ${delete_2}    read
    log    ${delete_2}
    sleep    5s
    write    ${Base_cmd_1} down ; ${Base_cmd_2} ${Int_Name} down ; ${Delete_cmd_2}
    ${delete_3}    read
    log    ${delete_3}
    sleep    5s
    #Create New Configuration
    write    ${Create_cmd_1} ; ${Base_cmd_1} up ; ${Link_set_cmd} ${Int_Name} ${netns_cmd} ; ${Base_cmd_2} ${Int_Name} up
    ${create_1}    read
    log    ${create_1}
    should not contain    ${create_1}    ${UE_Verification_1}
    should not contain    ${create_1}    ${UE_Verification_2}
    sleep    5s
    write    ${Create_cmd_2} ${client_ip_/24} dev ${Int_Name}
    ${create_2}    read
    log    ${create_2}
    should not contain    ${create_1}    ${UE_Verification_1}
    should not contain    ${create_1}    ${UE_Verification_2}
    sleep    5s
    write    ${Create_cmd_3} ${client_ip_253} dev ${Int_Name}
    ${create_3}    read
    log    ${create_3}
    should not contain    ${create_1}    ${UE_Verification_1}
    should not contain    ${create_1}    ${UE_Verification_2}
    sleep    5s
    write    ${Create_cmd_3} ${client_ip_254} dev ${Int_Name}
    ${create_4}    read
    should not contain    ${create_1}    ${UE_Verification_1}
    should not contain    ${create_1}    ${UE_Verification_2}
    log    ${create_4}

Establish Curl command on UE Simulator
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    70s
    Establish Connection and Log In to AMB LAX pabot
    UE-Simulator Login
    write    ${Curl_Command} ${website_name}
    ${curl_output}   read    delay=10s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}

Esablish TCPDUMP on ABR1
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-1 Login
    sleep    20s
    write    rm -rf ${tmp_ABR1}
    write     ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tmp_ABR1}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    ABR-1 Login
    sshlibrary.get file    ${tmp_ABR1}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True



Esablish TCPDUMP on ABR2
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-2 Login
    sleep    20s
    write    rm -rf ${tmp_ABR2}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tmp_ABR2}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    ABR-2 Login
    sshlibrary.get file    ${tmp_ABR2}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True


Esablish TCPDUMP on ABR3
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-3 Login
    sleep    20s
    write    rm -rf ${tmp_ABR3}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tmp_ABR3}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    ABR-3 Login
    sshlibrary.get file    ${tmp_ABR3}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True



Esablish TCPDUMP on ABR4
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-4 Login
    sleep    20s
    write    rm -rf ${tmp_ABR4}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tmp_ABR4}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    ABR-4 Login
    sshlibrary.get file    ${tmp_ABR4}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True


Esablish TCPDUMP on ABR5
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-5 Login
    sleep    20s
    write    rm -rf ${tmp_ABR5}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tmp_ABR5}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    ABR-5 Login
    sshlibrary.get file    ${tmp_ABR5}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True


Esablish TCPDUMP on ABR6
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-6 Login
    sleep    20s
    write    rm -rf ${tmp_ABR6}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tmp_ABR6}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    ABR-6 Login
    sshlibrary.get file    ${tmp_ABR6}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on ABR7
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-7 Login
    sleep    20s
    write    rm -rf ${tmp_ABR7}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tmp_ABR7}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    ABR-7 Login
    sshlibrary.get file    ${tmp_ABR7}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True


Esablish TCPDUMP on ABR8
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Establish Connection and Log In to AMB LAX pabot
    ABR-8 Login
    sleep    20s
    write    rm -rf ${tmp_ABR8}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tmp_ABR8}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    ABR-8 Login
    sshlibrary.get file    ${tmp_ABR8}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True


Esablish TCPDUMP on RSX1
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    RSX-1 Login
    sleep    20s
    write    rm -rf ${tmp_RSX1}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_RSX1}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    RSX-1 Login
    sshlibrary.get file    ${tmp_RSX1}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on RSX2
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    RSX-2 Login
    sleep    20s
    write    rm -rf ${tmp_RSX2}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_RSX2}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    RSX-2 Login
    sshlibrary.get file    ${tmp_RSX2}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on RSX3
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    RSX-3 Login
    sleep    20s
    write    rm -rf ${tmp_RSX3}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_RSX3}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    RSX-3 Login
    sshlibrary.get file    ${tmp_RSX3}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True


Esablish TCPDUMP on RSX4
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    RSX-4 Login
    sleep    20s
    write    rm -rf ${tmp_RSX4}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_RSX4}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    RSX-4 Login
    sshlibrary.get file    ${tmp_RSX4}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on RSX5
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    RSX-5 Login
    sleep    20s
    write    rm -rf ${tmp_RSX5}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_RSX5}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    RSX-5 Login
    sshlibrary.get file    ${tmp_RSX5}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on RSX6
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    RSX-6 Login
    sleep    20s
    write    rm -rf ${tmp_RSX6}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_RSX6}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    RSX-6 Login
    sshlibrary.get file    ${tmp_RSX6}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on RSX7
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    RSX-7 Login
    sleep    20s
    write    rm -rf ${tmp_RSX7}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_RSX7}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    RSX-7 Login
    sshlibrary.get file    ${tmp_RSX7}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on RSX8
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    RSX-8 Login
    sleep    20s
    write    rm -rf ${tmp_RSX8}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_RSX8}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    RSX-8 Login
    sshlibrary.get file    ${tmp_RSX8}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on AAA1
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    AAA-1 Login
    sleep    20s
    write    rm -rf ${tmp_AAA1}
    write    ${TCPDUMP_CMD_ANY} -w ${tmp_AAA1}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    AAA-1 Login
    sshlibrary.get file    ${tmp_AAA1}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on AAA2
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    AAA-2 Login
    sleep    20s
    write    rm -rf ${tmp_AAA2}
    write    ${TCPDUMP_CMD_ANY} -w ${tmp_AAA2}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    AAA-2 Login
    sshlibrary.get file    ${tmp_AAA2}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on XEPA1
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    XEPA-1 Login
    sleep    20s
    write    rm -rf ${tmp_XEPA1}
    write    ${TCPDUMP_CMD_ANY} -w ${tmp_XEPA1}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    XEPA-1 Login
    sshlibrary.get file    ${tmp_XEPA1}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on XEPA2
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    XEPA-2 Login
    sleep    20s
    write    rm -rf ${tmp_XEPA2}
    write    ${TCPDUMP_CMD_ANY} -w ${tmp_XEPA2}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    XEPA-2 Login
    sshlibrary.get file    ${tmp_XEPA2}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on WCS1
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    WCS-1 Login
    sleep    20s
    write    rm -rf ${tmp_WCS1}
    write    ${TCPDUMP_CMD_ANY} -w ${tmp_WCS1}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    WCS-1 Login
    sshlibrary.get file    ${tmp_WCS1}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True

Esablish TCPDUMP on WCS2
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    WCS-2 Login
    sleep    20s
    write    rm -rf ${tmp_WCS2}
    write    ${TCPDUMP_CMD_ANY} -w ${tmp_WCS2}
    sleep    40s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    close connection
    Establish Connection and Log In to AMB LAX pabot
    WCS-2 Login
    sshlibrary.get file    ${tmp_WCS2}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
