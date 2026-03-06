*** Settings ***



*** Variables ***
${ssh_command}    sshpass -p
${ssh_o_command}    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -t
${connec_time_out}    Connection timed out
${No_route}    No route to host
${expected_running_services}    13
${expected_exited_services}    2
${default}    default
${undlay-vrf33}    169.254.201.33
${undlay-vrf34}    169.254.201.34
${IP_of_Core}    172.30.255.1
${IP_of_staging_Core}    172.30.255.10
${IP_of_PortableNW_zz0}    172.30.136.36
${pattern}    ./pattern/
${IP_of_Core_Singapore}    172.30.255.2
${ABRS_json_path}    ABRS.json
${Common_Path}    Data
${active}    Active: active (exited)
${success}    status=0/SUCCESS
${running1}    Active: active (running)
${out}    out
${not_found}    command not found
${cto}    Connection timed out
${pass_status}    code=exited, status=0/SUCCESS)
${IAD}    IAD_Site_Package.json
${online}    Online
${offline}    Offline
${enable}    active/enabled
${mcast}    mcast
${inactive}    inactive (dead)
${failed_status}    failed
${mcastgroup}    239.255.1.1
${running}    Active: active (running)
${out}    out
${permission}    Permission denied
${notrunning}    bgpd is not running
${AAA_Simulator}    AAA-IAD01-01
${active_run}    active (running)
${FRA04}    FRA04_Site_Package.json
${FRA04_Simulator}    AAA-FRA04
${MEL}    MEL_Site_Package.json
${SYD}    SYD_Site_Package.json
${SYD_Simulator}    AAA-SYD01
${MEL_Simulator}    AAA-MEL01
${ATL}    ATL01_Site_Package.json
${LAX}    LAX01_Site_Package.json
${singapore_AAA}    AAA_singapore.json
${peer_regex}    (?s)Peer(.*?)s of memory
${cmd_data_total_regex_nccli}    (?s)Total(.*?)>
${brkout_rgx}    BRKOUT_[0-9][0-9]
${ORD}    ORD01_Site_Package.json
${DFW}    DFW_Site_Package.json
${QRO}    QRO_Site_Package.json
${YMQ}    YMQ_Site_Package.json
${TYO}    TYO_Site_Package.json
${MAD}    MAD_Site_Package.json
${PAR}    PAR_Site_Package.json
${FRA08}    FRA08_Site_Package.json
${GRU}    GRU_Site_Package.json
${LON}    LON_Site_Package.json
${LON02}    LON02_Site_Package.json
${HKG}    HKG_Site_Package.json
${EWR}    EWR_Site_Package.json
${DUB}    DUB_Site_Package.json
${ABR}    ABR_Site_Package.json
${DEN}    DEN_Site_Package.json
${found}    found
${site_name_rgx}    ^([A-Z]+)[0-9][0-9]
${collector_ID_rgx}    (?:01_(?:01|02)|02_(?:01|02)|04_(?:01|02)|08_(?:01|02))
${site_id_rgx}    ^([A-Z]+)
${cpra_rgx}    cpra.+?\ +
@{VRFS}           default    vrf1    vrf2    vrf3    vrf4    vrf5
@{VRFS1}    vrf1    vrf2    vrf3    vrf4    vrf5
${VTYSH_NODE}     custrsx
${IP_PREFIX}        194.35.39
${MIN_IP_COUNT}    6