printStatusCEMU () {
	echo
    echo $2;        #       echo in CEMU; return;

    # Check if pointed it Core or Emulator and if pingable
    appProperties=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'cat /opt/os-emulator/config/application.properties' 2>&1`; 
    xepaip=`echo "$appProperties" | grep ^xepa.ip | cut -f 2 -d = | xargs | cut -f 1 -d " "`

    xepaipPresent=accessbrokerPresent=canPresent=""
    if [[ -z $appProperties ]]; then logError " - Server is not reachable"; return; 
    elif [[ $appProperties == "No such file or directory" ]]; then logError " - No such file or directory"; return;
    else [[ $xepaip != "172.30."* ]] && logError " - Configure xepa in /opt/os-emulator/config/application.properties" || xepaipPresent=True
    fi;
#       echo xepaip = $xepaip

#       vtep=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$ABR1 grep vtep /etc/hosts | cut -f 1 -d " "`
#       accessbroker=`echo "$appProperties" | grep "$vtep" | cut -f 2 -d =`; 

    accessbroker=`echo "$appProperties" | grep ^cib.accessbroker.addr | cut -f 2 -d =`; 
    [[ -z "$accessbroker" ]] && logError " - ABR vteps not configured" || accessbrokerPresent=True
#       echo accessbroker = $accessbroker


    aaaCan=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$AAA1 grep can_name /etc/radiusd.d/radiusd.conf | grep can | grep -v \# | xargs | awk '{ print $3 }'`
    [[ -z "$aaaCan" ]] && echo Could not access the AAA server || can=`echo "$appProperties" | grep $aaaCan | cut -f 2 -d =`; 
    [[ -z "$can" ]] && logError " - CAN is not configured" || canPresent=True

#       echo aaaCan = $aaaCan
    echo can = $can

    [[ $xepaipPresent && $accessbrokerPresent && $canPresent ]] && echo - Configurations are good || echo - Issue at cemu

    echo iptables check
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$CemuIp iptables-save`
    if [[ -z $ip_returned ]]; 
    then echo - IP tables not configured
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$CemuIp clean_iptable.sh`
    else echo - IP tables not configured
    fi;


    echo Ping Test
    Dest1=Dest2=""
    xepaip=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep xepa.ip /opt/os-emulator/config/application.properties | cut -f 2 -d =`
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 ping -c 2 -I ens192 $xepaip 2>&1`;
        if [[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]]; then Dest1=true; 
        else logError " - xepa is not pingable"; fi

    aaaInterfaceEth1=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$AAA1 grep IPADDR /etc/sysconfig/network-scripts/ifcfg-eth1 | cut -f 2 -d =`
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 ping -c 2 -I undlay-vrf $aaaInterfaceEth1 2>&1`;
        if [[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]]; then Dest2=true;
        else logError " - undlay-vrf 169.254.201.34 is not pingable"; fi

    [[ $Dest1 && $Dest2 ]] && echo - Both AAA and Xepa are pingable
}

pingIP () {
	Ping_Sever_IP=$2
	resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping -c 2 -I eth1 $Ping_Sever_IP" 2>&1`;
	if [[ $resp == *" 0% packet loss"* ]]; then echo - $Ping_Sever_IP is reachable; else logError " - $Ping_Sever_IP is not reachable"; checkgw=Yes;fi
}

printStatusAAA () {
	echo
    echo $2
	serverIP=$1
    # Version command add - /usr/local/sbin/radiusd -v 
    respAll=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 '/usr/local/sbin/radiusd -v | grep Version; ps -ef | grep tpyd | grep -v grep; ps -ef | grep radius | grep -v grep; grep ^orch_server /etc/apex.d/tpyd.sysconf; grep eth2 /usr/local/var/log/apex.log | tail -1'`
    if [[ -z $respAll ]]; then logError " - Server is not reachable"; return; fi; 
    
    resp=`echo "$respAll" | grep FreeRADIUS | awk '{ print $4 }' | cut -f 3 -d / | cut -f 1 -d ,`
    if [[ -z $resp ]]; then logError " - Radius version is not found"; else echo - Radius server version is $resp; fi; 

    resp=`echo "$respAll" | grep tpyd | awk '{ print $2 }'`
    if [[ -z $resp ]]; then logError " - Apex server is not running"; else echo - Apex server is running fine; fi; 
    
    resp=`echo "$respAll" | grep radius | awk '{ print $2 }'`
    if [[ -z $resp ]]; then logError " - Radius server is not running"; else echo - Radius server is running fine; fi; 

    # Check if running as Master or Backup
    resp=`echo "$respAll" | grep eth2 | awk '{ print $NF }'`
    if [[ -z $resp ]]; then logError " - Logs are misssing which tell if the server is Master or Slave"; else echo - Server is $resp; fi; 

    checkgw=No
    # Check if pointed it Core or Emulator and if pingable
    ip_returned=`echo "$respAll" | grep orch_server | awk '{ print $3 }'`;

#<<"COMMENT"
	case "$ip_returned" in
        "$IP_of_Core") 
			echo - Server is pointing to Core; 
			;;
        "$IP_of_PortableNW_zz0") 
			echo - Server is pointing to Portable Network # Portable network.
            ;;
        172.30."$ThirdOctetOfSiteIP".36) 
			echo - Server is pointing to Emulator;  # CEMU IP.
            ;;
        "$IP_of_Emulator") 
			echo - Server is pointing to Emulator deployed on AAA Sim;  # FRA14 is the only site on which CEMU was deployed on AAA simulator.
            ;;
        *)
            logError " - Something is wrong, instead of Core or Emulator the response returned is" $ip_returned;
            ;;
	esac
	pingIP "$serverIP" "$ip_returned"
#COMMENT

    if [[ $checkgw == Yes ]];
    then
        gatewayip=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep 172.30.255 /etc/sysconfig/network-scripts/route-eth1 | awk '{ print $3 }'`
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 ping -c 2 -I eth1 "$gatewayip" 2>&1`;
        [[ "$resp" == *"2 packets transmitted, 2 received, 0% packet loss"* ]] && echo - Gateway is pingable || logError " - Gateway is not pingable"
    fi
}

printStatusDCR () {
	echo
    echo $2
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'ip addr | grep global | wc -l' 2>&1`
    if [[ $resp == *Connection\ timed\ out* ]]; then logError " - Server does not exist"; return;
    elif [[ -z $resp ]]; then logError " - Something wrong, please check DCR connectivity"; return;
    elif [[ $resp -lt 7 ]]; then logError " - Something wrong, as the ip addr spwaned are - $resp, which is less than expected count of 7"
    elif [[ $resp -gt 7 ]]; then logError " - Something wrong, as the ip addr spwaned are - $resp, which is more than expected count of 7"
    else echo - ip addr loops good as all IPs including loopback are instantiated.
    fi

    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'systemctl status bind9.service | egrep "Loaded|Active|Process|PID" 2>&1'`
    if [[ $resp == *"Active: active (running)"* ]]; then echo - bind9.service is running fine.; else logError " - Something wrong please check the bind9 service"; fi;

    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'systemctl status networking.service' 2>&1`;
    if [[ $resp == *" (code=exited, status=0/SUCCESS)"* ]]; then echo - networking.service is running fine.; else logError " - Something wrong with the networking service"; fi;

    dns=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 cat /etc/network/interfaces.d/lo.cfg | grep address | head -1 | xargs | cut -f 2 -d " " | cut -f 1 -d "/"`
    if [[ -z $dns ]]; 
    then dns=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 cat /etc/network/interfaces.d/lo1.cfg | grep address | head -1 | xargs | cut -f 2 -d " " | cut -f 1 -d "/"`
    fi;

    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping 1.1.1.1 -I $dns -c 2" 2>&1`;
    [[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]] && echo - Internet is reachable from $2 || logError " - Internet not working"

    printStatusDCR_BGP $1 $2
}

printStatusDCR_BGP () {
    echo show bgp sum statistics
    resp=resp_count=resp_BR1_IP=resp_BR2_IP=resp_BR1_Status=resp_BR2_Status=""
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 vtysh -c \"show bgp sum\"`;
    if [[ -z $resp ]]; 
    then logError " - Server is not reachable"; return; 
    else 
        resp_count=`echo "$resp" | grep 172.31 | awk '{ print $10 }' | grep [a-z,A-Z] | wc -l 2>&1`;
        if [[ $resp_count -eq 0 ]]; then echo - Both BRs are reachable;
        elif [[ $resp_count -eq 2 ]]; then logError " - Both BRs are down"; 
        else
            resp_BR1_IP=`echo "$resp" | grep 172.31 | head -1 | awk '{ print $1 }' 2>&1`;
            resp_BR1_Status=`echo "$resp" | grep 172.31 | head -1 | awk '{ print $10 }' | grep [a-z,A-Z] | wc -l 2>&1`;
            [[ $resp_BR1_Status -eq 1 ]] && logError " - Issue with BR " $resp_BR1_IP;

            resp_BR2_IP=`echo "$resp" | grep 172.31 | tail -1 | awk '{ print $1 }' 2>&1`;
            resp_BR2_Status=`echo "$resp" | grep 172.31 | tail -1 | awk '{ print $10 }' | grep [a-z,A-Z] | wc -l 2>&1`;
            [[ $resp_BR2_Status -eq 1 ]] && logError " - Issue with BR " $resp_BR2_IP;
        fi;
    fi;

    echo
    echo show ip bgp statistics
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 vtysh -c \"sh ip bgp\"`;
    #Loopbacks=`echo "$resp"    | grep -v BGP | egrep "170.199|192.33" | wc -l`
    Loopbacks_170=`echo "$resp"     | grep -v BGP | grep 170.199 | wc -l`
    Loopbacks_192=`echo "$resp"     | grep -v BGP | grep 192.33 | wc -l`
    if [[ $Loopbacks_170 != "0" ]]; then Loopbacks=$Loopbacks_170
    elif [[ $Loopbacks_192 != "0" ]]; then Loopbacks=$Loopbacks_192
    else logError " - loopback address are not spwaned."
    fi

    [[ $Loopbacks -ne 5 ]] && logError " - One or more of 5 loopback IPs are not spawned" || statusLoopbacks=true

    nextHops=`echo "$resp" | grep 172.31 | wc -l`
    [[ $nextHops -lt 2 ]] && logError " - One or both next hops to BRs are not connected" || statusNextHops=true

    [[ $statusLoopbacks && $statusNextHops ]] && echo - As expected: 5 loopback and 2 BR next hops are connected

}

printStatusRSX () {
	echo
    echo $2
    respAll=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'ip addr | grep global; systemctl status answerx.service | egrep "Loaded|Active|Process|PID"; cat /etc/network/interfaces.d/lo.cfg | grep address | head -1 | xargs; ss | grep tcp | grep bgp | grep ESTAB; vtysh -c "show bgp sum" | egrep "169.254|172.31"; vtysh -c "sh ip bgp"' 2>&1`
    if [[ $respAll == *Connection\ timed\ out* ]]; then logError " - Server does not exist"; return;
    elif [[ -z $respAll ]]; then logError " - Something wrong, please check RSX connectivity"; return;
	fi

    resp=`echo "$respAll" | grep global | wc -l`
    if [[ $resp -lt 10 ]]; then logError " - Something wrong, as the ip addr spwaned are - $resp, which is less than expected count of 8"
    elif [[ $resp -gt 10 ]]; then logError " - Something wrong, as the ip addr spwaned are - $resp, which is more than expected count of 8"
    else echo - ip addr loops good as all IPs including loopback are instantiated.
    fi

    resp=`echo "$respAll" | egrep "Loaded|Active|Process|PID"`
    if [[ $resp == *"Active: active (exited)"* && $resp == *"status=0/SUCCESS"* ]]; then echo - answerx.service is running fine.; else logError " - Something wrong please check the answerx service"; fi;
	
    loopbackInterfaceIP=`echo "$respAll" | grep address | awk '{ print $2 }' | awk -F / '{print $1}'`
    if [[ -z $loopbackInterfaceIP ]]; 
    then loopbackInterfaceIP=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 cat /etc/network/interfaces.d/lo1.cfg | grep address | head -1 | xargs | cut -f 2 -d " " | cut -f 1 -d "/"`
    fi;

    #       echo Internet access from RSX - 
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping 1.1.1.1 -I $loopbackInterfaceIP -c 2" 2>&1`;
    if [[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]]; then echo - Internet is reachable from $2.; else logError " - Internet not working"; fi;

    # Alternate internet access check command -
#       resp=`dig -b 127.0.0.1 hdfc.com @$loopbackInterfaceIP`
#       if [[ $resp == *"status: NOERROR"* ]]; then echo - Internet is reachable from $2.; else logError " - Internet not working"; fi;

    printStatusRSX_BGP "$respAll"
}

printStatusRSX_BGP () {
	respAll="$1"

    echo TCP Statistics
    resp=`echo "$respAll" | grep bgp | grep ESTAB`;
    totalCount=`echo "$resp" | grep ESTAB | wc -l`
        if [[ $totalCount -ne 4 ]]; 
        then logError " - One or more BGP sockets are disconnected from Peers";
            ABR=`echo "$resp" | egrep ".3:|.4:" | wc -l`
            BR=`echo "$resp" | egrep ".1:|.2:" | wc -l`
            [ $ABR -lt 2 ] && logError " -- One or both BGP connections to ABRs are down"
            [ $BR -lt 2 ] && logError " -- One or both BGP connections to BRs are down"
        else echo - All ABR and BR sockets are connected; 
        fi
 
    echo
    echo "show bgp sum" statistics
	resp=`echo "$respAll" | egrep "^169.254|^172.31" | awk '{ print $1": "$10 }'`;

    totalCount=`echo "$resp" | grep : | wc -l`
    if [[ $totalCount -ne 4 ]]; 
    then 
        ABR=`echo "$resp" | egrep ".3:|.4:" | wc -l`
        BR=`echo "$resp" | egrep ".1:|.2:" | wc -l`
        [ $ABR -lt 2 ] && logError " - One or both BGP connections to ABRs are down"
        [ $BR -lt 2 ] && logError " - One or both BGP connections to BRs are down"
    else echo - All ABRs and BRs are connected;  
    fi


    echo
    echo "sh ip bgp" statistics
    statusRoute=statusPath=statusMultipath=statusPublicDNS=statusInternalDNS=statusNextHops=""
    resp_displayed=`echo "$respAll" | grep Displayed`
        echo - "$resp_displayed";
            if [[ "$resp_displayed" != *"8 routes"* ]]; then logError " - 8 routes are expected"; else statusRoute=true; fi
            if [[ "$resp_displayed" != *"9 total paths"* ]]; then logError " - 9 paths are expected"; else statusPath=true; fi

        publicDNS=`echo "$respAll" | grep 170.199 | wc -l`
        [ $publicDNS -lt 1 ] && logError " - Public DNS 170.199.xx.xx is not initialized" || statusPublicDNS=true

        internalDNS=`echo "$respAll" | grep 194.35. | grep 0.0.0.0 | wc -l`
        [ $internalDNS -lt 6 ] && logError " - One or more internal DNS 194.35.xx.xx is not initialized" || statusInternalDNS=true

        nextHops=`echo "$respAll" | grep 172.31.11 | grep -v ^172.31.11 | wc -l`
        [ $nextHops -lt 2 ] && logError " - One or both next hops to BRs are disconnected" || statusNextHops=true

    [[ $statusRoute && $statusPath && $statusPublicDNS && $statusInternalDNS && $statusNextHops ]] && echo - Both of the next hops to BRs, 6 internal RSX IPs and 1 public DNS is published

}

printStatusXepa () {
    [[ $2 == "XEPA"*"TEST" ]] && return 1;
	echo
    echo $2
    # Check the version
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep pre xepa.log | tail -1 | cut -f 2 -d "(" | cut -f 1 -d ")" 2>&1`;
    if [[ -n $resp ]]; 
    then echo - Version is "$resp"; 

    else 
    ##### Below 2 lines are only when running the script in lab and not on production as xepa deamon is termincated.
#        `sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "xepa.term" 2>&1`;
#        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep pre xepa.log | tail -1 | cut -f 2 -d "(" | cut -f 1 -d ")" 2>&1`;
        echo - Version is "$resp";
        #       echo - Version log rolled over
    fi

    resp_MasterOrSlave=SLAVE
    # Check if running as Master or Backup
    resp_MasterOrSlave_pattern=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 tail -10 /usr/local/var/log/xepa.log 2>&1`;
    totalCount=`echo "$resp_MasterOrSlave_pattern" | grep keepalive | wc -l`
    [[ $totalCount -gt 1 ]] && resp_MasterOrSlave=MASTER


#       # Check if running as Master or Backup
#       resp_MasterOrSlave=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep eth1 /usr/local/var/log/xepa.log | tail -1 | cut -f2 -d ">" | xargs 2>&1`;
#       if [[ -z $resp_MasterOrSlave ]]; then 
#       ##### Below lines are only when running the script in lab and not on production as xepa deamon is termincated.
#           `sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "xepa.term;xepa.proc" 2>&1`;
#           echo - printStatusXepa $vm_ip $vm_hostname; # Looping since the status is not visible
#       else echo - Server is running as $resp_MasterOrSlave;
#       fi;

##### Below lines are for production to replace above lines. Safer option to identify the Master as we want to avoid restarting xepa
#       resp_MasterOrSlave=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep eth1 /usr/local/var/log/xepa.log | tail -1 | cut -f2 -d ">" | xargs 2>&1`;
#       if [[ -n $resp_MasterOrSlave ]]; 
#           then echo - Server is running as $resp_MasterOrSlave; 
#       elif
#           resp_keepaliveTime=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep keepalive xepa.log | awk '{ print $3 }'`
#           sleep 7;
#           resp_keepaliveTime1=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep keepalive xepa.log | awk '{ print $3 }'`
#           if [[ -n $resp_keepaliveTime && -n $resp_keepaliveTime1 ]]; 
#           then resp_MasterOrSlave=Master; echo - Server is running as Master; 
#           else resp_MasterOrSlave=Slave; echo - Server is running as Slave;  
#           fi
#       fi;


    # Check if Singapore Core IP is set properly or not
    if [[ $sitename == "Mel" || $sitename == "Syd" ]]; 
    then ip_OrchSrvr=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep 172.30.255 /usr/local/xepa/OrchSrvr.py | awk '{ print $4 }' | cut -f 1 -d ")"`; 
        [[ $ip_OrchSrvr != *"172.30.255.2"* ]] && logError " - Expected Singapore Core IP at /usr/local/xepa/OrchSrvr.py"; 
    fi


    ### This is not wotkng --- Recheck
    # Check if pointed Core or Emulator
    ip_returned=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep ^OrchSrvr.addr /etc/xepa.d/tpyd.sysconf | cut -f3 -d " "`; 
    if [[ -z $ip_returned ]]; 
        then logError " - Core IP is missing from tpyd.conf"; 
        return; 
    fi;


    checkgw=No
    if [[ $ip_returned == $IP_of_Core ]]; 
    then 
        echo - Server is pointing to Core; 
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping -c 2 -I eth1 $IP_of_Core" 2>&1`;
        if [[ $resp == *"2 packets transmitted, 2 received,"* ]] && [[ $resp == *" 0% packet loss"* ]]; then echo - Core is reachable; else logError " - Core is not reachable"; checkgw=Yes;fi
    elif [[ $ip_returned == $IP_of_PortableNW_zz0 ]] 
    then 
        echo - Server is pointing to Portable Network # Portable network.
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping -c 2 -I eth1 $IP_of_PortableNW_zz0" 2>&1`;
        if [[ $resp == *" 0% packet loss"* ]]; then echo - CEMU with portable network is reachable; else logError " - CEMU with portable network is not reachable"; checkgw=Yes;fi
    elif [[ $ip_returned == "172.30.$ThirdOctetOfSiteIP.36" ]]; 
    then 
        echo - Server is pointing to Emulator;  # CEMU IP.
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping -c 2 -I eth1 172.30.$ThirdOctetOfSiteIP.36" 2>&1`;
        if [[ $resp == *" 0% packet loss"* ]]; then echo - CEMU is reachable; else logError " - CEMU is not reachable"; checkgw=Yes;fi
    elif [[ $ip_returned == $IP_of_Emulator ]]; 
    then 
        echo - Server is pointing to Emulator deployed on AAA Sim;  # FRA14 is the only site on which CEMU was deployed on AAA simulator.
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping -c 2 -I eth1 $IP_of_Emulator" 2>&1`;
        if [[ $resp == *" 0% packet loss"* ]]; then echo - Emulator is reachable; else logError " - Emulator is not reachable"; checkgw=Yes;fi
    else logError " - Something is wrong, instead of Core or Emulator the response returned is" $ip_returned; 
    fi


    if [[ $checkgw == Yes ]];
    then
        gatewayip=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep 172.30.255 /etc/sysconfig/network-scripts/route-eth1 | awk '{ print $3 }'`
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 ping -c 2 -I eth1 "$gatewayip" 2>&1`;
        [[ "$resp" == *"2 packets transmitted, 2 received, 0% packet loss"* ]] && echo - Gateway is pingable || logError " - Gateway is not pingable"
    fi

    if [[ -z $resp_MasterOrSlave ]]; 
    then logError " - Can't check if ABR is connected with XEPA as XEPA logs are rolled over and can't determine if it is Master"; 
    else 
        if [[ $resp_MasterOrSlave == "MASTER" ]]; 
        then

        echo - TCP Statistics
        tcp_resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 netstat -a | grep http 2>&1`
        totalCount=`echo "$tcp_resp" | grep 172.30.255 | grep ESTABLISHED | wc -l`
        [[ $totalCount -lt 1 ]] && logError "  - TCP:Connection to Core/CEMU is down" || echo  - TCP:Connection to Core/CEMU is established
        abrCount=`echo "$tcp_resp" | grep ESTABLISHED | awk '{ print $5 }' | grep -v 172.30.255.2 | wc -l`
        [[ $abrCount -lt 1 ]] && logError "  - TCP:Connection to ABRs is down" || echo  - TCP:Total ABRs with established status are $abrCount

            noOfAbr=`grep ABR ./sitedata/$vm_list | wc -l`  # vm_list inherited from ./config/configAndSite file
            # Attempt for altenative approch   currentTime=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 date | cut -f 4 -d " "`
            # noOfAbr=2 # setting temporarily to restrict to 2 ABRs only.

            naname1=naname2=naname3=naname4=""
            [ -n "$ABR1" ] && naname1=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$ABR1 grep naname /etc/hosts | awk '{ print $3 }' | cut -f 2 -d .`
            [ -n "$ABR3" ] && naname2=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$ABR3 grep naname /etc/hosts | awk '{ print $3 }' | cut -f 2 -d .`
            [ -n "$ABR5" ] && naname3=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$ABR5 grep naname /etc/hosts | awk '{ print $3 }' | cut -f 2 -d .`
            [ -n "$ABR7" ] && naname4=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$ABR7 grep naname /etc/hosts | awk '{ print $3 }' | cut -f 2 -d .`

            i=1; abr=""
            while [[ $i -ne $noOfAbr ]]
            do
                if [[ "$i" == 1 ]] || [[ "$i" == 2 ]]; then naname=$naname1; fi
                if [[ "$i" == 3 ]] || [[ "$i" == 4 ]]; then naname=$naname2; fi
                if [[ "$i" == 5 ]] || [[ "$i" == 6 ]]; then naname=$naname3; fi
                if [[ "$i" == 7 ]] || [[ "$i" == 8 ]]; then naname=$naname4; fi
                [ -z $naname ] && break

                if [[ "$i" == 1 ]] || [[ "$i" == 2 ]] || [[ "$i" == 3 ]] || [[ "$i" == 5 ]]; then abr=abr1; fi
                if [[ "$i" == 2 ]] || [[ "$i" == 4 ]] || [[ "$i" == 6 ]] || [[ "$i" == 8 ]]; then abr=abr2; fi

                resp_keepaliveTime=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep keepalive xepa.log | grep "$abr.$naname" | tail -1 | awk '{ print $3 }'`
                if [[ -z $resp_keepaliveTime ]]; 
                then logError " - Xepa is not connected to" "$abr.$naname"; 
                else sleep 10;
                resp_keepaliveTime1=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep keepalive xepa.log | grep "$abr.$naname" | tail -1 | awk '{ print $3 }'`
                if [[ $resp_keepaliveTime < $resp_keepaliveTime1 ]]; 
                then echo - Xepa is connected to "$abr.$naname"; 
                else echo "Xepa connectivity is lost with" "$abr.$naname"; fi
                fi
            i=`expr $i + 1`
            done
        fi
    fi

}

printStatusCIBR () {
	echo
    echo $2

####
#   Block for checking the version secursively.
#       cibr_resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "lrd -v" 2>&1`
#       if [[ -z $cibr_resp || $cibr_resp == *out* ]]; then echo - Server does not exist; 
#       elif [[ "$cibr_resp" == *" not found"* ]]; then resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep PEER /etc/opt/cibr/cibr.conf`
#       else resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep Servers.from -A 3 /etc/rd@[0,1].d/rd.toml | grep 172.30 | grep -v \# 2>&1`;
#       fi
#           echo "$resp"
#      return
####

    cibr_resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "lrd -v" 2>&1`
    if [[ -z $cibr_resp || $cibr_resp == *out* ]]; then echo - Server does not exist; 
    elif [[ "$cibr_resp" == *" not found"* ]]; then 

        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 systemctl status cibr-lrd.service | egrep \"Loaded\|Active\|PID\"`
        resp_rd0=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 systemctl status cibr-rd-1.service | egrep \"Loaded\|Active\|PID\"`
        resp_rd1=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 systemctl status cibr-rd-2.service | egrep \"Loaded\|Active\|PID\"`
        if [[ $resp == *"Active: active (running)"* ]]; then echo - cibr-lrd.service is running fine.; else logError " - Something wrong please check the cibr-lrd.service"; fi;
        if [[ $resp_rd0 == *"Active: active (running)"* ]]; then echo - cibr-rd-1.service is running fine.; else logError " - Something wrong please check the cibr-rd-1.service"; fi;
        if [[ $resp_rd1 == *"Active: active (running)"* ]]; then echo - cibr-rd-2.service is running fine.; else logError " - Something wrong please check the cibr-rd-2.service"; fi;

        CIBP1=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "grep PEER_1 /etc/opt/cibr/cibr.conf  | cut -f 2 -d =" 2>&1`
        CIBP2=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "grep PEER_2 /etc/opt/cibr/cibr.conf  | cut -f 2 -d =" 2>&1`
        if [[ -z "$CIBP1" || -z "$CIBP2" ]]; then echo CIBP is not configured; return; fi

        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 ss | grep tcp | grep 172.30.11 | grep ESTAB | awk '{ print $6 }' 2>&1`;
        count=`echo "$resp" | egrep "$CIBP1|$CIBP2" | wc -l`
        if [[ $count -lt 2 ]]; then logError " - TCP:One or both CIBP connections are down"; else echo - TCP:Both CIBP connections are up; fi

        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "timeout 11 tcpdump -p -i ens192 -nn src $CIBP1 -c 2" 2>&1`;
        count=`echo "$resp" | grep $CIBP1 | wc -l`
        if [[ $count -gt 0 ]]; then echo - TCP:$2 - $CIBP1 connection is up; else logError " - TCP:$2 - $CIBP1 connection is down"; fi

        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "timeout 11 tcpdump -p -i ens192 -nn src $CIBP2 -c 2" 2>&1`;
        count=`echo "$resp" | grep $CIBP2 | wc -l`
        if [[ $count -gt 0 ]]; then echo - TCP:$2 - $CIBP2 connection is up; else logError " - TCP:$2 - $CIBP2 connection is down"; fi
    else 
        echo - version $cibr_resp; 
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 systemctl status lrd | egrep \"Loaded\|Active\|PID\"`
        resp_rd0=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 systemctl status rd@0 | egrep \"Loaded\|Active\|PID\"`
        resp_rd1=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 systemctl status rd@1 | egrep \"Loaded\|Active\|PID\"`
        if [[ $resp == *"Active: active (running)"* ]]; then echo - lrd is running fine.; else logError " - Something wrong please check the lrd service"; fi;
        if [[ $resp_rd0 == *"Active: active (running)"* ]]; then echo - rd@0 is running fine.; else logError " - Something wrong please check the rd@0 service"; fi;
        if [[ $resp_rd1 == *"Active: active (running)"* ]]; then echo - rd@1 is running fine.; else logError " - Something wrong please check the rd@1 service"; fi;

        CIBP1=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep Servers.from /etc/rd@0.d/rd.toml -A 4 | grep IP | grep -v "#" | xargs | awk '{ print $3 }' 2>&1`
        CIBP2=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 grep Servers.from /etc/rd@1.d/rd.toml -A 4 | grep IP | grep -v "#" | xargs | awk '{ print $3 }' 2>&1`
        if [[ -z "$CIBP1" || -z "$CIBP2" ]]; then echo CIBP is not configured; return; fi

        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 ss | grep tcp | grep ESTAB | awk '{ print $6 }' 2>&1`;
        count=`echo "$resp" | egrep "$CIBP1|$CIBP2" | wc -l`
        if [[ $count -lt 2 ]]; then logError " - TCP:One or both CIBP connections are down"; else echo - TCP:Both CIBP connections are up; fi

        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "timeout 11 tcpdump -p -i eth1 -nn src $CIBP1 -c 2" 2>&1`;
        count=`echo "$resp" | grep $CIBP1 | wc -l`
        if [[ $count -gt 0 ]]; then echo - TCPDUMP:$2 - $CIBP1 traffic is flowing; else logError " - TCP:$2 - $CIBP1 traffic not is flowing"; fi

        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "timeout 11 tcpdump -p -i eth1 -nn src $CIBP2 -c 2" 2>&1`;
        count=`echo "$resp" | grep $CIBP2 | wc -l`
        if [[ $count -gt 0 ]]; then echo - TCPDUMP:$2 - $CIBP2 traffic is flowing; else logError " - TCP:$2 - $CIBP2 traffic not is flowing"; fi
    fi
}

printStatusABR () {
	echo
    echo $2
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'cat /var/lib/portables/abr/.vars | egrep "BASELINE|VERSION"' 2>&1`;
    baseline=`echo "$resp" | grep BASELINE`
    version=`echo "$resp" | grep VERSION`

    if [[ $resp == *Connection\ timed\ out* ]]; then echo - Connection Timed Out. Instance does not exist; return;
    elif [[ $resp == *No\ route\ to\ host* ]]; then echo - No route to host exists; return;
    else 
        echo - ABR Baseline "$baseline";
        echo - ABR Version "$version";

        respAll=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'cat /var/lib/portables/abrhost/.vars; cat /etc/hosts; systemctl list-units "abr-*"; ip route show vrf a2b2a; ss | grep tcp' 2>&1`;
        baseline=`echo "$respAll" | grep BASELINE`
        version=`echo "$respAll" | grep VERSION`
        echo - ABRHost Baseline "$baseline";
        echo - ABRHost Version "$version";

		connectedXepa=`echo "$respAll" | grep control:http | awk '{print $6}' | cut -f 1 -d :`
		echo connectedXepa=$connectedXepa
		if [[ -n $connectedXepa && $connectedXepa == *".101" ]]; then echo " - ABR is connected to CEMU"; fi;
		if [[ -n $connectedXepa && $connectedXepa == *".2[4|5]" ]]; then echo " - ABR is connected to Core"; fi;


		xepavip=`echo "$respAll" | grep xepa.control | grep -v ^# | cut -f 1 -d " "`
		if [[ -z $xepavip ]]; then logError " - XEPA VIP is not found in ABR etc"; return;   ###  abr i
		else 
			resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping -c 2 -I control $xepavip" 2>&1`
			if [[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]]; then echo - xepavip is reachable; else logError " - xepavip is not reachable"; fi
		fi
		resp_running=`echo "$respAll" | grep running | wc -l 2>&1`;
        resp_exited=`echo "$respAll" | grep exited | wc -l 2>&1`;

        if [[ $resp == *"0 loaded units listed"* ]]; then logError " - All services of ABR are down"; 
        elif [[ $resp_running == 13 ]] && [[ $resp_exited == 2 ]]; then echo - In all 15 ABR services are executing. Running count is $resp_running and Exited count is $resp_exited; 
        elif [[ $resp_running == 12 ]] && [[ $resp_exited == 2 ]]; then echo - In all 14 ABR services are executing. Running count is $resp_running and Exited count is $resp_exited; 
        elif [[ $resp_running == 11 ]] && [[ $resp_exited == 2 ]]; then echo - In all 13 ABR services are executing. Running count is $resp_running and Exited count is $resp_exited; 
        elif [[ $resp_running == 10 ]] && [[ $resp_exited == 2 ]]; then echo - In all 12 ABR services are executing. Running count is $resp_running and Exited count is $resp_exited; 
        else 
            if [[ $resp_running < 10 ]]; then logError " - Please check ABR services as less running services are running"
            else logError " - Something wrong with ABR Services, Please check"
            fi;
        fi;

        resp=`echo "$respAll" | grep ^default`
        if [[ -z $resp ]]; then logError " - Default route is not found for brkout interface, please check vrf a2b2a";
        else echo - vrf a2b2a has default route
        fi
    fi;

    CIBRCount=CIBR1Count=CIBR2Count=0
    resp=`echo "$respAll" | grep control | grep ESTAB`;
    CIBRCount=`echo "$resp" | egrep ".20:77|.21:77|.36:77" | wc -l`
    CIBR1Count=`echo "$resp" | egrep ".20:77" | wc -l`
    CIBR2Count=`echo "$resp" | egrep ".21:77" | wc -l`
    CIBR3CountCemu=`echo "$resp" | egrep ".36:77" | wc -l`

    if [[ $CIBR3CountCemu -eq 1 ]]; then echo - TCP:CEMU connection is up; fi

    if [[ $CIBRCount -eq 2 ]]; then echo - TCP:Both CIBR connections are up; 
    elif [[ $CIBRCount -lt 2 ]]; then 
        [[ $CIBR1Count -lt 1 ]] && logError " - TCP:CIBR1 connection is down"
        [[ $CIBR2Count -lt 1 ]] && logError " - TCP:CIBR2 connection is down"
    else logError " - TCP:Issue with CIBR connectivity";
    fi

    XepaCount=`echo "$resp" | grep http | wc -l`
    if [[ $XepaCount -lt 1 ]]; then logError " - TCP:Xepa connection is down"; else echo - TCP:Xepa connection is up; fi

#   Call BGP function first
    printStatusABR_BGP $1 $2
}

printStatusABR_BGP () {
    echo; # return
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'ss | grep tcp | grep bgp | grep ESTAB' 2>&1`
    if [[ $resp == *Connection\ timed\ out* ]]; then logError " - Connection Timed Out. Instance does not exist"; 
    elif [[ $resp == *No\ route\ to\ host* ]]; then logError " - No route to host exists to" $2; 
    else 
        echo TCP Statistics
#        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'ss | grep tcp | grep bgp | grep ESTAB' 2>&1`
        totalCount=`echo "$resp" | grep ESTAB | wc -l`
        if [[ $totalCount -ne 8 ]];
        then 
            undlay=`echo "$resp" | grep undlay | wc -l`
            RSX=`echo "$resp" | egrep ".5:|.6:" | wc -l`
            PGW=`echo "$resp" | egrep ".13:|.14:" | wc -l`
            CGNAT=`echo "$resp" | egrep ".23:|.24:" | wc -l`
            [ $undlay -lt 2 ] && logError " - One or both Undlay TCP connections are down"
            [ $RSX -lt 2 ] && logError " - RSX:One or both connections are down"
            [ $PGW -lt 2 ] && logError " - PGW:One or both connections are down"
            [ $CGNAT -lt 2 ] && logError " - CGNAT:One or both connections are down"
        else echo - All sockets for 2 Undlay, 2 RSXs, 2 PGWs and 2 CGNATs are connected; 
        fi

        echo
        echo "show bgp sum" statistics
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 vtysh -c \"show bgp sum\" | egrep ^169.254\|^172.31 | awk '{ print $1": "$10 }'`
        totalCount=`echo "$resp" | grep : | wc -l`
        if [[ $totalCount -ne 6 ]];
        then
            RSX=`echo "$resp" | egrep ".5:|.6:" | wc -l`
            PGW=`echo "$resp" | egrep ".13:|.14:" | wc -l`
            CGNAT=`echo "$resp" | egrep ".23:|.24:" | wc -l`
            [ $RSX -lt 2 ] && logError " - RSX:One or both connections are down"
            [ $PGW -lt 2 ] && logError " - PGW:One or both connections are down"
            [ $CGNAT -lt 2 ] && logError " - CGNAT:One or both connections are down"
        else echo - All 6 neighbors\(2 Access GWs, RSXs and CGNATs\) are connected;
        fi
		
		echo
        echo "sh ip bgp vrf undlay-vrf" statistics
        respAll=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'cat /etc/opt/abr/naname.conf; cat /etc/hosts' 2>&1`;
		cbrVTEP=RR1=RR2=""
        cbrVTEP=`echo "$respAll" | grep 194.35.38.2 | cut -f 5 -d ,`
		RR=`echo "$respAll" | grep evpn-rr.vxborder | head -1 | cut -f 1 -d . | wc -l`
#		RR2=`echo "$respAll" | grep evpn-rr.vxborder | tail -1 | cut -f 1 -d .`
		
		
        respAll=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'vtysh -c "sh ip bgp vrf undlay-vrf"' 2>&1`;
        cbrVTEPRoutePresent=`echo "$respAll" | grep -A 1 "$cbrVTEP" | wc -l` 
        RRCount=`echo "$respAll" | grep -A 1 "$cbrVTEP" | wc -l` 
		[[ "$cbrVTEPRoutePresent" -lt 2 ]] && logError " - One or more of CBRs are disconnected" || echo - Connected cbrVTEPRoutePresent=$cbrVTEPRoutePresent
		[[ "$RR" -lt 2 ]] && logError " - One or more of RRs are disconnected" || echo - Connected RRCount=$RRCount
		echo
		
		
		echo "sh ip bgp" statistics
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'vtysh -c "sh ip bgp"' 2>&1`;
        resp_displayed=`echo "$resp" | grep Displayed`
        echo "$resp_displayed";
        statusRoute=statusPath=statusMultipath=statusBestRoute=statusRSX=statusRSXHopsfor5=statusRSXHopsfor6=""
#            [[ "$resp_displayed" != *"11 routes"* ]] && logError " - 11 routes are expected" || statusRoute=true
#            [[ "$resp_displayed" != *"16 total paths"* ]] && logError " - 16 paths are expected" || statusPath=true

            localMultipath=`echo "$resp" | grep -A 3 0.0.0.0/0 | grep ^*= | wc -l`
            [[ "$localMultipath" -lt 1 ]] && logError " - Local Multipath does not exists" || statusMultipath=true

            localBestRoute=`echo "$resp" | grep -A 3 0.0.0.0/0 | grep ^*\> | wc -l`
            [[ "$localBestRoute" -lt 1 ]] && logError " - Local best route does not exists" || statusBestRoute=true

            RSXIps=`echo "$resp" | grep 194.35.39.1 | wc -l`
            [[ "$RSXIps" -lt 9 ]] && logError " - One or more of expected 9 RSX IPs to BRKOUTs are disconnected" || statusRSX=true

            RSXNextHops_5=`echo "$resp" | grep 169.254.2[0-3]3.5 | wc -l`
            [[ "$RSXNextHops_5" -lt 6 ]] && logError " - One or more of expected 6 next hops from RSX IPs to 169.254.203.5 are disconnected" || statusRSXHopsfor5=true

            RSXNextHops_6=`echo "$resp" | grep 169.254.2[0-3]3.6 | wc -l`
            [[ "$RSXNextHops_6" -lt 6 ]] && logError " - One or more of expected 6 next hops from RSX IPs to 169.254.203.6 are disconnected" || statusRSXHopsfor6=true

            [[ $statusMultipath && $statusBestRoute && $statusRSX && $statusRSXHopsfor5 && $statusRSXHopsfor6 ]] && echo - All next hops from RSX IPs to BRKOUTs are published

		resp_PrivateRange=`echo "$resp" | grep 169.254 | cut -f 3 -d " " | grep ^10.`
		echo - Private range anounced by MNO is "$resp_PrivateRange"
		
        echo
        echo Ping Test
        Dest1=Dest2=""
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'ping -c 2 -I undlay-vrf 169.254.201.33' 2>&1`;
            if [[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]]; then Dest1=true; 
            else logError " - undlay-vrf 169.254.201.33 is not pingable"; fi
        resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'ping -c 2 -I undlay-vrf 169.254.201.34' 2>&1`;
            if [[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]]; then Dest2=true;
            else logError " - undlay-vrf 169.254.201.34 is not pingable"; fi

        [[ $Dest1 && $Dest2 ]] && echo - Both undlay-vrfs are pingable
    fi;
}

printStatusCOL () {
	echo
    echo $2
    #return;

    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 pcs status 2>&1`
    if [[ $resp == *Connection\ timed\ out* ]]; then echo $2 do not exist; 
    elif [[ $resp == *"1.cluster: Online"* && $resp == *"2.cluster: Online"* ]]; then echo - Cluster is online.; 
    else logError " - Something wrong please check" $2; 
    fi

    if [[ $resp == *"corosync: active/enabled"* ]]; then echo - corosync is running fine.; else logError " - Something wrong please check the corosync"; fi;
    if [[ $resp == *"pacemaker: active/enabled"* ]]; then echo - pacemaker is running fine.; else logError " - Something wrong please check the pacemaker"; fi;
    if [[ $resp == *"pcsd: active/enabled"* ]]; then echo - pcsd is running fine.; else logError " - Something wrong please check the pcsd"; fi;
}

printStatusProxy () {
	echo
    echo $2
    
	resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'systemctl status squid.service; systemctl status pacemaker.service; ping 1.1.1.1 -I eth1 -c 2; cat /etc/hosts 2>&1'`
	filtered=`echo "$resp" | grep -A 4 squid.service | egrep "squid|Loaded|Active|Process|PID"`
	[[ $filtered == *"Loaded: loaded"* && $filtered == *"Active: active"* ]] && echo - squid.service is loaded and running fine || logError " - Something wrong please check the squid.service"

	filtered=`echo "$resp" | grep -A 4 pacemaker.service | egrep "pacemaker|Loaded|Active|Process|PID"`
	[[ $filtered == *"Loaded: loaded"* && $filtered == *"Active: active"* ]] && echo - pacemaker.service is loaded and running fine || logError " - Something wrong please check the pacemaker.service"
 
	[[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]] && echo - Internet is reachable from $2 || logError " - Internet not working"

	clusterCount=""
	clusterCount=`echo "$resp" | grep cluster | wc -l`
	[[ $clusterCount -lt 2 ]] && logError " - cluster configurations are missing in /etc/hosts file"
}

printStatusWCS () {
	echo
    echo $2
	resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 'cat /etc/zvelo.d/zvelo.conf; systemctl status zvelo-server.service; systemctl status zvelo-database-updater.service; systemctl status zvelo-database-downloader.service; cat /etc/network/interfaces 2>&1'`
	if [[ $resp == *Connection\ timed\ out* ]]; then echo - Server does not exist; 
	else 
    wcs_resp_zvelo=`echo "$resp" | grep mcast | grep -v \#`
    
    mcast_interface=`echo "$resp" | grep -A 30 "The loopback network interface" | grep 172.30 | xargs | cut -f 2 -d " "`
    	
    [[ $wcs_resp_zvelo == *$mcast_interface* && $wcs_resp_zvelo == *"mcast_group = 239.255.1.1"* ]] && echo - mcast_iface_ips and mcast_group is set || logError " - Something wrong with mcast_iface_ips and mcast_group configurations at /etc/zvelo.d/zvelo.conf please check"
    
    zvelo_resp=`echo "$resp" | grep -A 5 zvelo-server.service | egrep "zvelo|Loaded|Active|PID"`
    [[ $zvelo_resp == *"Active: active (running)"* ]] && echo - zvelo-server.service is running fine || logError " - Something wrong please check the zvelo-server.service"

    wcs_resp_dbupdater=`echo "$resp" | grep -A 10 zvelo-database-updater.service | egrep "updater|Loaded|Active|PID"`
    [[ $wcs_resp_dbupdater == *"(code=exited, status=0/SUCCESS)"* ]] && echo - zvelo-database-updater.service is running fine || logError " - Something wrong please check the wcs_resp_dbupdater"

#    wcs_resp_dbdownloader=`echo "$resp" | grep -A 10 zvelo-database-downloader.service | egrep "downloader|Loaded|Active|PID"`
#    [[ $wcs_resp_dbdownloader == *"(code=exited, status=0/SUCCESS)"* ]] && echo - zvelo-database-downloader.service is running fine || logError " - Something wrong please check the wcs_resp_dbdownloader"
	fi
}

printStatusVPNNAT_BGP () {
    echo $2;
    resp=brkout1=brkout2=brkout3=BRs=""
    echo "show bgp vrf all summary" statistics
    resp=`sshpass -f $passfile6w ssh -o ConnectTimeout=10 -n $user_rt@$1 vtysh -c \"show bgp vrf all summary\" 2>&1`
    if [[ "$resp" == "bgpd is not running" ]]; then logError " - bgpd is not running"
    else 
#		totalConfigured=`echo "$resp" | egrep "^169.254|^172.31" | awk '{ print $1 }' | wc -l`
		nonConnected=`echo "$resp" | egrep "^169.254|^172.31" | awk '{ print $1": "$10 }' | grep [a-zA-Z] | wc -l`
		if [[ $nonConnected -gt 0 ]];
		then
			brkout1=`echo "$resp" | grep "^169.254.203" | awk '{ print $1": "$10 }' | grep [a-zA-Z] | wc -l`
			brkout2=`echo "$resp" | grep "^169.254.213" | awk '{ print $1": "$10 }' | grep [a-zA-Z] | wc -l`
			brkout3=`echo "$resp" | grep "^169.254.223" | awk '{ print $1": "$10 }' | grep [a-zA-Z] | wc -l`
			BRs=`echo "$resp" | grep "^172.31" | awk '{ print $1": "$10 }' | grep [a-zA-Z] | wc -l`
			[ "$brkout1" -gt 0 ] && logError " - One or both brkout1 connections are down"
			[ "$brkout2" -gt 0 ] && logError " - One or both brkout2 connections are down"
			[ "$brkout3" -gt 0 ] && logError " - One or both brkout3 connections are down"
			[ "$BRs" -gt 0 ] && logError " - One or both BR connections are down"
		else echo - As expected all 6 BRKOUTs and 2 BRs neighbours are connected
		fi
    fi

#       resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 "ping 1.1.1.1 -c 2" 2>&1`;
#       [[ $resp == *"2 packets transmitted, 2 received, 0% packet loss"* ]] && echo - Internet is reachable from $2 || logError " - Internet not working"

}

printStatusPN () {
	echo
    echo $2
    echo Checks are yet to be added
}

printStatusISL () {
	echo
    echo $2
    echo Checks are yet to be added
}

printStatusCIB2BGP () {
 	echo
    echo $2
    echo Checks are yet to be added
}

executeCommands () {
	echo
    echo $2
    command="ip addr"
    # Version command add - /usr/local/sbin/radiusd -v 
    resp=`sshpass -f $passfile ssh -o ConnectTimeout=10 -n $user_rt@$1 $command`
    if [[ -z $resp ]]; then logError " - Radius version is not found"; return; 
    else echo "$resp"; fi; 
}


