*** Settings ***
Library    OperatingSystem

*** Variables ***
${Host}     nms-ixdub1-01.eu1.infra.asavie.net
${denv_host}    nms-l3den-01.us1.infra.asavie.net
${singapore_host}    nms-t3sin-01.ap1.infra.asavie.net
${denv_username}    shjosh
${denv_psw}     Shubham2811!
${Host2}    172.24.67.33
${AMB_LAX01}    172.24.21.40
${AMB_LAX01_12}    172.24.21.41
${AMB_FRA14}    88.205.101.54
${AAA_YMQ_Simulator}    172.24.55.33
${AAA_LAX_Simulator}    172.24.22.33
${AAA_FRA08_Simulator}    172.24.67.33
${TX-LAX-Root}    192.33.27.6
${TS-LAX-PWD}    bLm4WmdR8CRO5kAOi7t9
${USERNAME}     cdhingra
${USERNAME_ABR}    root
${PASSWORD}     radumu4e
${PASSWORD1}    p$50KsSq3OzH
${PASSWORD_ABR}    H66*5FU!vwX*
${PASSWORD3}    vnyhQHHA*Hiq
${PASSWORD_FRA08}   p$50KsSq3OzH
${vault_password}    4$1chH7&kVa9&mN&a#9uC^fpy3
${PASSWORD_Simulator}    XcC0$78l0liJ
${dff_dir_1}    Tcpdumpdata
${FRA14_port}    5024
${input}    yes
${IP_Add}   ip addr add
${IP_Del}    ip addr del
${dev}    dev
${dff_dir}    Health_Check
${SSH_NoCLient_Ask}    ssh -o "StrictHostKeyChecking no"
${Health_check_directory}    cd /root/rahulb/beanshells
${Radius_Message_directory}     cd /root/testClient/
${Health_check_execution}    ./check_apps_status.sh
${site_name}    Fra04
#${Radius_Message_execution}     ./testapex_working -D -cfg cfg_examples/cfg_CAN902_de_AAASim.yml -scn fullsession_CAN902.xml_bk_verizon-12_us
${Radius_Message_execution}     ./testapex_working -D -cfg cfg_examples/cfg_CAN902_de_AAASim.yml -scn fullsession_CAN001_Core_internet.xml
${client_latch_cmd}    ip route show table clients
${Present_working_directory}    pwd
${Verify_Beanshells}    beanshells
${Verify_testClient}    testClient
${Health_check}    health_check.txt
${Radiusregex}  >.+?}
${IPregex}     (?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
${3oct_IPreg}    (?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
${USERNAME1}    root
${Pwd}     $4naCB3aojjZ
${vtysh_cmd}     vtysh
${bgp_cmd}    sh ip bgp summary
${cmd_data_regex}   (?s)IPv(.*?)B of memory
${cmd_data_total_regex}    (?s)Total(.*?)#
${dff_dir_bgp}    BGP_Status
${BGP_Status_txt}   bgp_txtfile.txt
${BGP_check_final}   bgp_status_final.csv
${BGP_out_final}    BGP_out.csv
${whitespace_regex}     \ +
${comma_seperator}      ,
${state_column}     State/PfxRcd
${up_dowm_column}       Up/Down
${AAA-Master_Regex}     AAA.+?MASTER
${AAA-Backup_Regex}     AAA.+?BACKUP
${XEPA}     XEPA
${XEPA-02_Regex}     XEPA.+?02
${CIBR}    CIBR
${CIBR-02-Regex}    CIBR.+?02
${CIBR_Copy_regex}    Copyright
${pre_regex}        pre.*?C
${get_number_regex}     [0-9]+
${WCS}     WCS
${01}     01
${02}   02
${WCS-02_regex}     WCS.+?02
${COL}      COL
${PCSD Status}      PCSD Status:
${Daemon Status}    Daemon Status:
${COL-01_regex}     (?s)COL(.*?)01(.*?)01
${COL-02_regex}     COL.+?02
${is_word}      is
${1st_rgx}        (?s)
${2nd_rgx}        (.*?)
${64byts}       64 bytes
${0% packet loss}   0% packet loss
${Destination_Host_Unreachable}     Destination Host Unreachable
${Something_is_wrong}    Something is wrong
${active/enabled}    active/enable
${Online}       Online
${dead}     dead
${running}      running
${zvelo-server}     zvelo-server.service
${zvelo-downloader}     zvelo-database-downloader.service
${zvelo-updater}       zvelo-database-updater
${corosync}     corosync
${pacemaker}    pacemaker
${pcsd}     pcsd
${104}      104
${prod}      PROD
${prod-02}      PROD.+?02
${pacemaker-service}    pacemaker.service
${squid-service}    squid.service
${cluster}      .cluster
${failed}     failed
${ONLINE}    Online

${taillab_cmd}    tailab -T client -n 5 -f /var/opt/akamai/abr/abd.d/tombs/log.tomb
${Radiusregex}  >.+?}
${tcpdump_dir}    TCP_Dumps
${kill_tcpdump_cmd}    kill $(ps -e | pgrep tcpdump)
${Radius_Message_directory}     cd /root/testClient/
${Verify_testClient}    testClient
${client_latch_cmd}    ip route show table clients
${dev_lo}    dev lo
${Curl_Command}    ip netns exec GI_Source curl -I
${unresolve_host}    Could not resolve host
${Unresolve_device}    Cannot find device
${match}     AAA-LAX01-SIMULATOR
${TCPDump_CMD_ABR}    tcpdump -p -i access -nn
${TCPDUMP_CMD_RSX}    tcpdump -p -i any -nn "net 10.128.0.0/10"
${TCPDUMP_CMD_ANY}    tcpdump -i any -p -s 9000
${tmp_ABR1}    /tmp/ABR1.pcap
${tmp_ABR2}    /tmp/ABR2.pcap
${tmp_ABR3}    /tmp/ABR3.pcap
${tmp_ABR4}    /tmp/ABR4.pcap
${tmp_ABR5}    /tmp/ABR5.pcap
${tmp_ABR6}    /tmp/ABR6.pcap
${tmp_ABR7}    /tmp/ABR7.pcap
${tmp_ABR8}    /tmp/ABR8.pcap
${tmp_RSX1}    /tmp/RSX1.pcap
${tmp_RSX2}    /tmp/RSX2.pcap
${tmp_RSX3}    /tmp/RSX3.pcap
${tmp_RSX4}    /tmp/RSX4.pcap
${tmp_RSX5}    /tmp/RSX5.pcap
${tmp_RSX6}    /tmp/RSX6.pcap
${tmp_RSX7}    /tmp/RSX7.pcap
${tmp_RSX8}    /tmp/RSX8.pcap
${tmp_AAA1}    /tmp/AAA1.pcap
${tmp_AAA2}    /tmp/AAA2.pcap
${tmp_XEPA1}    /tmp/XEPA1.pcap
${tmp_XEPA2}    /tmp/XEPA2.pcap
${tmp_WCS1}    /tmp/WCS1.pcap
${tmp_WCS2}    /tmp/WCS2.pcap

#UE Simulator Configuration Commands
${Delete_cmd_1}    ip netns exec GI_Source ip route del 0.0.0.0/0 via
${Delete_cmd_2}    ip netns del GI_Source
${Base_cmd_1}    ip netns exec GI_Source ip link set lo
${Base_cmd_2}    ip netns exec GI_Source ip link set
${Create_cmd_1}    ip netns add GI_Source
${Create_cmd_2}    ip netns exec GI_Source ip addr add
${Create_cmd_3}    ip netns exec GI_Source ip route add 0.0.0.0/0 via
${Link_set_cmd}    ip link set
${netns_cmd}    netns GI_Source
${UE_Verification_1}    Cannot find device
${UE_Verification_2}    No such device

#WBR Testing Data for daily run FRA04
${Radius_Message_execution_WBR}    ./testapex_working -D -cfg cfg_examples/cfg_CAN902_de_AAASim.yml -scn E2E_fullsession_CAN001_Core_WBR.xml
${http}    http://
${webserver_IP}    10.38.38.2
${Common_Path}    Data


