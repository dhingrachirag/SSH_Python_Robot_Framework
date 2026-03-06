*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
Library    String
Library    Collections
Resource   ../Variables/globalvariables.robot
Resource   ../Variables/pabotglobalvariables.robot
Resource   ../Variables/Authentication_variables.robot
Library     CryptoLibrary    variable_decryption=False

*** Variables ***


*** Keywords ***

Establish Connection and Log In for Denv-NMS EU
    ${username}=    Get Decrypted Text    ${Shubham_nms_username}
    log    ${username}
    ${password}=    Get Decrypted Text    ${Shubham_nms_pass}
    log    ${password}
    ${output}     open connection
    ...     ${Host}
    Log    ${output}
    ${Display}    login
    ...     ${username}
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
    Establish Connection AMB Server EU

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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
    ...    jumphost_index_or_alias=2

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

Executing Radius command and get IP of Client assigned by CORE pabot
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    Establish Connection and Log In to AMB LAX pabot
    write     ${SSH_NoCLient_Ask} ${USERNAME1}@${AAA-Simulator}
    ${simulator}    read    delay=10s
    IF    $match in $simulator
        Write   ${Radius_Message_directory}
    ELSE
        sleep    15s
        should contain     ${simulator}    password:
        write    ${password}
        Write   ${Radius_Message_directory}
    END
    Write   ${Present_working_directory}
    ${out1}=    Read Until   ${Verify_testClient}
    log     ${out1}
    write   ${Radius_Message_execution}
    ${radius}   read    delay=10s
    log    ${radius}
#    should contain  ${radius}   PASS
    ${lines}=   should match regexp      ${radius}    ${Radiusregex}
    ${lines1}=  should match regexp     ${lines}     ${IPregex}
    log    ${lines}
    log    ${lines1}
    set global variable    ${lines1}
    [Return]    ${lines1}

Establish Radius Command in AAA Simulator APN Healthcheck
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    40s
    Establish Connection and Log In to AMB LAX pabot
    write     ${SSH_NoCLient_Ask} ${USERNAME1}@${APN-Health-Check-Simulator}
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
    ${radius}   read    delay=300s
    log    ${radius}
    should contain  ${radius}   PASS

Executing Radius command for ABR34
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    Establish Connection and Log In to AMB LAX pabot
    write     ${SSH_NoCLient_Ask} ${USERNAME1}@${AAA-Simulator}
    ${simulator}    read    delay=10s
    IF    $match in $simulator
        Write   ${Radius_Message_directory}
    ELSE
        sleep    15s
        should contain     ${simulator}    password:
        write    ${password}
        Write   ${Radius_Message_directory}
    END
    Write   ${Present_working_directory}
    ${out1}=    Read Until   ${Verify_testClient}
    log     ${out1}
    write   ${Radius_Message_execution_ABR34}
    ${radius}   read    delay=10s
    log    ${radius}
#    should contain  ${radius}   PASS
    ${lines}=   should match regexp      ${radius}    ${Radiusregex}
    ${lines1}=  should match regexp     ${lines}     ${IPregex}
    log    ${lines}
    log    ${lines1}
    set global variable    ${lines1}
    [Return]    ${lines1}

Check Client Attach to ABR and Configure UE Simulator on ABR1
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-1 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    IF    $client_ip in $client
        Establish Connection and Log In to AMB LAX pabot
        UE-Simulator Login
        write    ip netns del ABR12
        write    ip netns add ABR12
        write    ip link set ens192 netns ABR12
        ${out1}    read    delay=3s
        should not contain    ${out1}    ${UE_Verification_1}    msg= Need to reboot the UE Simulator Manually
        should not contain    ${out1}    ${UE_Verification_2}    msg= Need to reboot the UE Simulator Manually
        write    ip netns exec ABR12 ip link set ens192 up
        write    ip netns exec ABR12 ip addr add 169.254.202.100/24 dev ens192
        write    ip netns exec ABR12 ip link set lo up
        write    ip netns exec ABR12 ip addr add ${client_ip} dev lo
        write    ip netns exec ABR12 ip route add 0.0.0.0/0 via 169.254.202.3
        write    ip netns exec ABR12 iptables -t nat -A POSTROUTING -s 169.254.202.100/24 -d 0.0.0.0/0 -j SNAT --to-source ${client_ip}
        write    mkdir -p /etc/netns/ABR12
        write    cat <<EOF >/etc/netns/ABR12/resolv.conf
        write    nameserver 10.192.0.0
        write    EOF
    ELSE
        Fail    log    Client is not attached to ABR1
    END
    Establish Connection and Log In to AMB LAX pabot
    ABR-1 Login
    write    ip route add ${client_ip} via 169.254.202.100 dev access vrf a2b2a
    write    rm -rf ${tcp_1stABR_access}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_1stABR_access}
    Establish Connection and Log In to AMB LAX pabot
    ABR-1 Login
    write    rm -rf ${tcp_1stABR_brkout}
    write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_1stABR_brkout}
    Establish Connection and Log In to AMB LAX pabot
    UE-Simulator Login
    write    ip netns exec ABR12 curl -I ${website_name}
    ${curl_output}   read    delay=10s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}
    Establish Connection and Log In to AMB LAX pabot
    ABR-1 Login
    write    ip route del ${client_ip} via 169.254.202.100 dev access vrf a2b2a
    write    ${kill_tcpdump_cmd}
    sshlibrary.get file    ${tcp_1stABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    sshlibrary.get file    ${tcp_1stABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Check Client Attach to ABR and Configure UE Simulator on ABR2
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-2 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    IF    $client_ip in $client
        Establish Connection and Log In to AMB LAX pabot
        UE-Simulator Login
        write    ip netns del ABR12
        write    ip netns add ABR12
        write    ip link set ens192 netns ABR12
        ${out1}    read    delay=3s
        should not contain    ${out1}    ${UE_Verification_1}    msg= Need to reboot the UE Simulator Manually
        should not contain    ${out1}    ${UE_Verification_2}    msg= Need to reboot the UE Simulator Manually
        write    ip netns exec ABR12 ip link set ens192 up
        write    ip netns exec ABR12 ip addr add 169.254.202.100/24 dev ens192
        write    ip netns exec ABR12 ip link set lo up
        write    ip netns exec ABR12 ip addr add ${client_ip} dev lo
        write    ip netns exec ABR12 ip route add 0.0.0.0/0 via 169.254.202.4
        write    ip netns exec ABR12 iptables -t nat -A POSTROUTING -s 169.254.202.100/24 -d 0.0.0.0/0 -j SNAT --to-source ${client_ip}
        write    mkdir -p /etc/netns/ABR12
        write    cat <<EOF >/etc/netns/ABR12/resolv.conf
        write    nameserver 10.192.0.0
        write    EOF
    ELSE
        Fail    log    Client is not attached to ABR2
    END
    Establish Connection and Log In to AMB LAX pabot
    ABR-2 Login
    write    ip route add ${client_ip} via 169.254.202.100 dev access vrf a2b2a
    write    rm -rf ${tcp_2ndABR_access}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_2ndABR_access}
    Establish Connection and Log In to AMB LAX pabot
    ABR-2 Login
    write    rm -rf ${tcp_2ndABR_brkout}
    write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_2ndABR_brkout}
    Establish Connection and Log In to AMB LAX pabot
    UE-Simulator Login
    write    ip netns exec ABR12 curl -I ${website_name}
    ${curl_output}   read    delay=10s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}
    Establish Connection and Log In to AMB LAX pabot
    ABR-2 Login
    write    ip route del ${client_ip} via 169.254.202.100 dev access vrf a2b2a
    write    ${kill_tcpdump_cmd}
    sshlibrary.get file    ${tcp_2ndABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    sshlibrary.get file    ${tcp_2ndABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Check Client latch on ABR5 or ABR6
    ${client_latch_ABR5}=    Execute Client latch Command on ABR5
    ${client_latch_ABR6}=    Execute Client latch Command on ABR6
    IF    ${client_latch_ABR5} != ''    # Check if ABR5 variable is not empty
          log   ${client_latch_ABR5}
    ELSE IF    ${client_latch_ABR6} != ''    # Check if ABR6 variable is not empty
          log   ${client_latch_ABR6}
    ELSE
          log   Both variables are empty
    END


Execute Client latch Command on ABR5
    ${client_latch}=    Execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} ${client_latch_cmd}
    log    ${client_latch}
    [Return]    ${client_latch}

Execute Client latch Command on ABR6
    ${client_latch}=    Execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} ${client_latch_cmd}
    log    ${client_latch}
    [Return]    ${client_latch}

Check Client Attach to ABR and Configure UE Simulator on ABR4
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command for ABR34
    log    ${client_ip}
    sleep    30s
    Establish Connection and Log In to AMB LAX pabot
    ABR-4 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    IF    $client_ip in $client
        Establish Connection and Log In to AMB LAX pabot
        UE-Simulator Login
        write    ip netns del ABR34
        write    ip netns add ABR34
        write    ip link set ens224 netns ABR34
        ${out1}    read    delay=3s
        should not contain    ${out1}    ${UE_Verification_1}    msg= Need to reboot the UE Simulator Manually
        should not contain    ${out1}    ${UE_Verification_2}    msg= Need to reboot the UE Simulator Manually
        write    ip netns exec ABR34 ip link set ens224 up
        write    ip netns exec ABR34 ip addr add 169.254.212.100/24 dev ens224
        write    ip netns exec ABR34 ip link set lo up
        write    ip netns exec ABR34 ip addr add ${client_ip} dev lo
        write    ip netns exec ABR34 ip route add 0.0.0.0/0 via 169.254.212.8
        write    ip netns exec ABR34 iptables -t nat -A POSTROUTING -s 169.254.212.100/24 -d 0.0.0.0/0 -j SNAT --to-source ${client_ip}
        write    mkdir -p /etc/netns/ABR34
        write    cat <<EOF >/etc/netns/ABR34/resolv.conf
        write    nameserver 10.192.0.0
        write    EOF
    ELSE
        pass execution    log    Client is not attached to ABR4
    END
    Establish Connection and Log In to AMB LAX pabot
    ABR-4 Login
    write    ip route add ${client_ip} via 169.254.212.100 dev access vrf a2b2a
    write    rm -rf ${tcp_2ndABR_access}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_2ndABR_access}
    Establish Connection and Log In to AMB LAX pabot
    ABR-4 Login
    write    rm -rf ${tcp_2ndABR_brkout}
    write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_2ndABR_brkout}
    Establish Connection and Log In to AMB LAX pabot
    UE-Simulator Login
    write    ip netns exec ABR34 curl -I ${website_name}
    ${curl_output}   read    delay=10s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}
    Establish Connection and Log In to AMB LAX pabot
    ABR-4 Login
    write    ip route del ${client_ip} via 169.254.212.100 dev access vrf a2b2a
    close all connections

Check Client Attach to ABR and Configure UE Simulator on ABR5
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-5 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    IF    $client_ip in $client
        Establish Connection and Log In to AMB LAX pabot
        UE-Simulator Login
        write    ip netns del ABR56
        write    ip netns add ABR56
        write    ip link set ens256 netns ABR56
        ${out1}    read    delay=3s
        should not contain    ${out1}    ${UE_Verification_1}    msg= Need to reboot the UE Simulator Manually
        should not contain    ${out1}    ${UE_Verification_2}    msg= Need to reboot the UE Simulator Manually
        write    ip netns exec ABR56 ip link set ens256 up
        write    ip netns exec ABR56 ip addr add 169.254.222.100/24 dev ens256
        write    ip netns exec ABR56 ip link set lo up
        write    ip netns exec ABR56 ip addr add ${client_ip} dev lo
        write    ip netns exec ABR56 ip route add 0.0.0.0/0 via 169.254.222.9
        write    ip netns exec ABR56 iptables -t nat -A POSTROUTING -s 169.254.222.100/24 -d 0.0.0.0/0 -j SNAT --to-source ${client_ip}
        write    mkdir -p /etc/netns/ABR56
        write    cat <<EOF >/etc/netns/ABR56/resolv.conf
        write    nameserver 10.192.0.0
        write    EOF
    ELSE
        Fail    log    Client is not attached to ABR5
    END
    Establish Connection and Log In to AMB LAX pabot
    ABR-5 Login
    write    ip route add ${client_ip} via 169.254.222.100 dev access vrf a2b2a
    write    rm -rf ${tcp_1stABR_access}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_1stABR_access}
    Establish Connection and Log In to AMB LAX pabot
    ABR-5 Login
    write    rm -rf ${tcp_1stABR_brkout}
    write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_1stABR_brkout}
    Establish Connection and Log In to AMB LAX pabot
    UE-Simulator Login
    write    ip netns exec ABR56 curl -I ${website_name}
    ${curl_output}   read    delay=10s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}
    Establish Connection and Log In to AMB LAX pabot
    ABR-5 Login
    write    ip route del ${client_ip} via 169.254.222.100 dev access vrf a2b2a
    write    ${kill_tcpdump_cmd}
    sshlibrary.get file    ${tcp_1stABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    sshlibrary.get file    ${tcp_1stABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Check Client Attach to ABR and Configure UE Simulator on ABR6
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-6 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    IF    $client_ip in $client
        Establish Connection and Log In to AMB LAX pabot
        UE-Simulator Login
        write    ip netns del ABR56
        write    ip netns add ABR56
        write    ip link set ens256 netns ABR56
        ${out1}    read    delay=3s
        should not contain    ${out1}    ${UE_Verification_1}    msg= Need to reboot the UE Simulator Manually
        should not contain    ${out1}    ${UE_Verification_2}    msg= Need to reboot the UE Simulator Manually
        write    ip netns exec ABR56 ip link set ens256 up
        write    ip netns exec ABR56 ip addr add 169.254.222.100/24 dev ens256
        write    ip netns exec ABR56 ip link set lo up
        write    ip netns exec ABR56 ip addr add ${client_ip} dev lo
        write    ip netns exec ABR56 ip route add 0.0.0.0/0 via 169.254.222.10
        write    ip netns exec ABR56 iptables -t nat -A POSTROUTING -s 169.254.222.100/24 -d 0.0.0.0/0 -j SNAT --to-source ${client_ip}
        write    mkdir -p /etc/netns/ABR56
        write    cat <<EOF >/etc/netns/ABR56/resolv.conf
        write    nameserver 10.192.0.0
        write    EOF
    ELSE
        Fail    log    Client is not attached to ABR6
    END
    Establish Connection and Log In to AMB LAX pabot
    ABR-6 Login
    write    ip route add ${client_ip} via 169.254.222.100 dev access vrf a2b2a
    write    rm -rf ${tcp_2ndABR_access}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_2ndABR_access}
    Establish Connection and Log In to AMB LAX pabot
    ABR-6 Login
    write    rm -rf ${tcp_2ndABR_brkout}
    write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_2ndABR_brkout}
    Establish Connection and Log In to AMB LAX pabot
    UE-Simulator Login
    write    ip netns exec ABR56 curl -I ${website_name}
    ${curl_output}   read    delay=10s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}
    Establish Connection and Log In to AMB LAX pabot
    ABR-6 Login
    write    ip route del ${client_ip} via 169.254.222.100 dev access vrf a2b2a
    write    ${kill_tcpdump_cmd}
    sshlibrary.get file    ${tcp_2ndABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    sshlibrary.get file    ${tcp_2ndABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Check Client Attach to ABR and Configure UE Simulator on ABR7
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-7 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    IF    $client_ip in $client
        Establish Connection and Log In to AMB LAX pabot
        UE-Simulator Login
        write    ip netns del ABR78
        write    ip netns add ABR78
        write    ip link set ens161 netns ABR78
        ${out1}    read    delay=3s
        should not contain    ${out1}    ${UE_Verification_1}    msg= Need to reboot the UE Simulator Manually
        should not contain    ${out1}    ${UE_Verification_2}    msg= Need to reboot the UE Simulator Manually
        write    ip netns exec ABR78 ip link set ens161 up
        write    ip netns exec ABR78 ip addr add 169.254.232.100/24 dev ens161
        write    ip netns exec ABR78 ip link set lo up
        write    ip netns exec ABR78 ip addr add ${client_ip} dev lo
        write    ip netns exec ABR78 ip route add 0.0.0.0/0 via 169.254.232.11
        write    ip netns exec ABR78 iptables -t nat -A POSTROUTING -s 169.254.232.100/24 -d 0.0.0.0/0 -j SNAT --to-source ${client_ip}
        write    mkdir -p /etc/netns/ABR78
        write    cat <<EOF >/etc/netns/ABR78/resolv.conf
        write    nameserver 10.192.0.0
        write    EOF
    ELSE
        Fail    log    Client is not attached to ABR7
    END
    Establish Connection and Log In to AMB LAX pabot
    ABR-7 Login
    write    ip route add ${client_ip} via 169.254.232.100 dev access vrf a2b2a
    write    rm -rf ${tcp_1stABR_access}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_1stABR_access}
    Establish Connection and Log In to AMB LAX pabot
    ABR-7 Login
    write    rm -rf ${tcp_1stABR_brkout}
    write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_1stABR_brkout}
    Establish Connection and Log In to AMB LAX pabot
    UE-Simulator Login
    write    ip netns exec ABR78 curl -I ${website_name}
    ${curl_output}   read    delay=10s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}
    Establish Connection and Log In to AMB LAX pabot
    ABR-7 Login
    write    ip route del ${client_ip} via 169.254.232.100 dev access vrf a2b2a
    write    ${kill_tcpdump_cmd}
    sshlibrary.get file    ${tcp_1stABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    sshlibrary.get file    ${tcp_1stABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Check Client Attach to ABR and Configure UE Simulator on ABR8
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-8 Login
    Write    ${client_latch_cmd}
    ${client}   read    delay=10s
    log    ${client}
    IF    $client_ip in $client
        Establish Connection and Log In to AMB LAX pabot
        UE-Simulator Login
        write    ip netns del ABR78
        write    ip netns add ABR78
        write    ip link set ens161 netns ABR78
        ${out1}    read    delay=3s
        should not contain    ${out1}    ${UE_Verification_1}    msg= Need to reboot the UE Simulator Manually
        should not contain    ${out1}    ${UE_Verification_2}    msg= Need to reboot the UE Simulator Manually
        write    ip netns exec ABR78 ip link set ens161 up
        write    ip netns exec ABR78 ip addr add 169.254.232.100/24 dev ens161
        write    ip netns exec ABR78 ip link set lo up
        write    ip netns exec ABR78 ip addr add ${client_ip} dev lo
        write    ip netns exec ABR78 ip route add 0.0.0.0/0 via 169.254.232.12
        write    ip netns exec ABR78 iptables -t nat -A POSTROUTING -s 169.254.232.100/24 -d 0.0.0.0/0 -j SNAT --to-source ${client_ip}
        write    mkdir -p /etc/netns/ABR78
        write    cat <<EOF >/etc/netns/ABR78/resolv.conf
        write    nameserver 10.192.0.0
        write    EOF
    ELSE
        Fail    log    Client is not attached to ABR8
    END
    Establish Connection and Log In to AMB LAX pabot
    ABR-8 Login
    write    ip route add ${client_ip} via 169.254.232.100 dev access vrf a2b2a
    write    rm -rf ${tcp_2ndABR_access}
    write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_2ndABR_access}
    Establish Connection and Log In to AMB LAX pabot
    ABR-8 Login
    write    rm -rf ${tcp_2ndABR_brkout}
    write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_2ndABR_brkout}
    Establish Connection and Log In to AMB LAX pabot
    UE-Simulator Login
    write    ip netns exec ABR78 curl -I ${website_name}
    ${curl_output}   read    delay=10s
    log    ${curl_output}
    should not contain    ${curl_output}    ${unresolve_host}
    should not be empty   ${curl_output}
    Establish Connection and Log In to AMB LAX pabot
    ABR-8 Login
    write    ip route del ${client_ip} via 169.254.232.100 dev access vrf a2b2a
    write    ${kill_tcpdump_cmd}
    sshlibrary.get file    ${tcp_2ndABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    sshlibrary.get file    ${tcp_2ndABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections


Check TCPDumps on ABR12
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-1 Login
    Write    ${client_latch_cmd}
    ${client1}   read    delay=5s
    log    ${client1}
    Establish Connection and Log In to AMB LAX pabot
    ABR-2 Login
    Write    ${client_latch_cmd}
    ${client2}   read    delay=5s
    log    ${client2}
    IF    $client_ip in $client1
        Establish Connection and Log In to AMB LAX pabot
        ABR-1 Login
        write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_1stABR_access}
        Establish Connection and Log In to AMB LAX pabot
        ABR-1 Login
        write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_1stABR_brkout}
        sleep    150s
        write    ${kill_tcpdump_cmd}
        sleep    10s
        sshlibrary.get file    ${tcp_1stABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        sshlibrary.get file    ${tcp_1stABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        close all connections
    ELSE IF    $client_ip in $client2
        Establish Connection and Log In to AMB LAX pabot
        ABR-2 Login
        write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_2ndABR_access}
        sleep    3s
        Establish Connection and Log In to AMB LAX pabot
        ABR-2 Login
        write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_2ndABR_brkout}
        sleep    150s
        write    ${kill_tcpdump_cmd}
        sleep    10s
        sshlibrary.get file    ${tcp_2ndABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        sshlibrary.get file    ${tcp_2ndABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    ELSE
        fail    Log     No client latch
    END
    close all connections

Check TCPDumps on ABR34
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-3 Login
    Write    ${client_latch_cmd}
    ${client1}   read    delay=5s
    log    ${client1}
    Establish Connection and Log In to AMB LAX pabot
    ABR-4 Login
    Write    ${client_latch_cmd}
    ${client2}   read    delay=5s
    log    ${client2}
    IF    $client_ip in $client1
        Establish Connection and Log In to AMB LAX pabot
        ABR-3 Login
        write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_1stABR_access}
        Establish Connection and Log In to AMB LAX pabot
        ABR-3 Login
        write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_1stABR_brkout}
        sleep    150s
        write    ${kill_tcpdump_cmd}
        sleep    10s
        sshlibrary.get file    ${tcp_1stABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        sshlibrary.get file    ${tcp_1stABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        close all connections
    ELSE IF    $client_ip in $client2
        Establish Connection and Log In to AMB LAX pabot
        ABR-4 Login
        write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_2ndABR_access}
        sleep    3s
        Establish Connection and Log In to AMB LAX pabot
        ABR-4 Login
        write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_2ndABR_brkout}
        sleep    150s
        write    ${kill_tcpdump_cmd}
        sleep    10s
        sshlibrary.get file    ${tcp_2ndABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        sshlibrary.get file    ${tcp_2ndABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    ELSE
        fail    Log     No client latch
    END
    close all connections

Check TCPDumps on ABR56
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-5 Login
    Write    ${client_latch_cmd}
    ${client1}   read    delay=5s
    log    ${client1}
    Establish Connection and Log In to AMB LAX pabot
    ABR-6 Login
    Write    ${client_latch_cmd}
    ${client2}   read    delay=5s
    log    ${client2}
    IF    $client_ip in $client1
        Establish Connection and Log In to AMB LAX pabot
        ABR-5 Login
        write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_1stABR_access}
        Establish Connection and Log In to AMB LAX pabot
        ABR-5 Login
        write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_1stABR_brkout}
        sleep    150s
        write    ${kill_tcpdump_cmd}
        sleep    10s
        sshlibrary.get file    ${tcp_1stABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        sshlibrary.get file    ${tcp_1stABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        close all connections
    ELSE IF    $client_ip in $client2
        Establish Connection and Log In to AMB LAX pabot
        ABR-6 Login
        write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_2ndABR_access}
        sleep    3s
        Establish Connection and Log In to AMB LAX pabot
        ABR-6 Login
        write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_2ndABR_brkout}
        sleep    150s
        write    ${kill_tcpdump_cmd}
        sleep    10s
        sshlibrary.get file    ${tcp_2ndABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        sshlibrary.get file    ${tcp_2ndABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    ELSE
        fail    Log     No client latch
    END
    close all connections

Check TCPDumps on ABR78
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    ${client_ip}=    Executing Radius command and get IP of Client assigned by CORE pabot
    Log    ${client_ip}
    Establish Connection and Log In to AMB LAX pabot
    ABR-7 Login
    Write    ${client_latch_cmd}
    ${client1}   read    delay=5s
    log    ${client1}
    Establish Connection and Log In to AMB LAX pabot
    ABR-8 Login
    Write    ${client_latch_cmd}
    ${client2}   read    delay=5s
    log    ${client2}
    IF    $client_ip in $client1
        Establish Connection and Log In to AMB LAX pabot
        ABR-7 Login
        write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_1stABR_access}
        Establish Connection and Log In to AMB LAX pabot
        ABR-7 Login
        write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_1stABR_brkout}
        sleep    150s
        write    ${kill_tcpdump_cmd}
        sleep    10s
        sshlibrary.get file    ${tcp_1stABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        sshlibrary.get file    ${tcp_1stABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        close all connections
    ELSE IF    $client_ip in $client2
        Establish Connection and Log In to AMB LAX pabot
        ABR-8 Login
        write    ${TCPDump_CMD_ABR} "host ${client_ip}" -w ${tcp_2ndABR_access}
        sleep    3s
        Establish Connection and Log In to AMB LAX pabot
        ABR-8 Login
        write    ${TCPDump_CMD_brkout_ABR} "host ${client_ip}" -w ${tcp_2ndABR_brkout}
        sleep    150s
        write    ${kill_tcpdump_cmd}
        sleep    10s
        sshlibrary.get file    ${tcp_2ndABR_access}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
        sshlibrary.get file    ${tcp_2ndABR_brkout}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    ELSE
        fail    Log     No client latch
    END
    close all connections

Check TCPDumps on RSX12
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    20s
    Establish Connection and Log In to AMB LAX pabot
    RSX-1 Login
    write    rm -rf ${tmp_1stRSX}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_1stRSX}
    Establish Connection and Log In to AMB LAX pabot
    RSX-2 Login
    write    rm -rf ${tmp_2ndRSX}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_2ndRSX}
    sleep    150s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    sshlibrary.get file    ${tmp_2ndRSX}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    Establish Connection and Log In to AMB LAX pabot
    RSX-1 Login
    write    ${kill_tcpdump_cmd}
    sleep    10s
    sshlibrary.get file    ${tmp_1stRSX}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Check TCPDumps on RSX34
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    20s
    Establish Connection and Log In to AMB LAX pabot
    RSX-3 Login
    write    rm -rf ${tmp_1stRSX}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_1stRSX}
    Establish Connection and Log In to AMB LAX pabot
    RSX-4 Login
    write    rm -rf ${tmp_2ndRSX}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_2ndRSX}
    sleep    150s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    sshlibrary.get file    ${tmp_2ndRSX}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    Establish Connection and Log In to AMB LAX pabot
    RSX-3 Login
    write    ${kill_tcpdump_cmd}
    sleep    10s
    sshlibrary.get file    ${tmp_1stRSX}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Check TCPDumps on RSX56
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    20s
    Establish Connection and Log In to AMB LAX pabot
    RSX-5 Login
    write    rm -rf ${tmp_1stRSX}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_1stRSX}
    Establish Connection and Log In to AMB LAX pabot
    RSX-6 Login
    write    rm -rf ${tmp_2ndRSX}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_2ndRSX}
    sleep    150s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    sshlibrary.get file    ${tmp_2ndRSX}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    Establish Connection and Log In to AMB LAX pabot
    RSX-5 Login
    write    ${kill_tcpdump_cmd}
    sleep    10s
    sshlibrary.get file    ${tmp_1stRSX}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Check TCPDumps on RSX78
    ${password}=    Get Decrypted Text    ${DE_PASSWORD}
    log    ${password}
    sleep    20s
    Establish Connection and Log In to AMB LAX pabot
    RSX-7 Login
    write    rm -rf ${tmp_1stRSX}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_1stRSX}
    Establish Connection and Log In to AMB LAX pabot
    RSX-8 Login
    write    rm -rf ${tmp_2ndRSX}
    write    ${TCPDUMP_CMD_RSX} -w ${tmp_2ndRSX}
    sleep    150s
    write    ${kill_tcpdump_cmd}
    sleep    10s
    sshlibrary.get file    ${tmp_2ndRSX}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    Establish Connection and Log In to AMB LAX pabot
    RSX-7 Login
    write    ${kill_tcpdump_cmd}
    sleep    10s
    sshlibrary.get file    ${tmp_1stRSX}    ${EXECDIR}/${tcpdump_dir}    scp=ALL     scp_preserve_times=True
    close all connections

Browse Test Through UE Simulator
    ${Browse_Traffic_UE}=    Execute command    ${ssh_command} ${password} ${ssh_o_command} ${username}@${ABR-IP} ${UE_browse_traffic}
    log    ${Browse_Traffic_UE}