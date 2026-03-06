*** Settings ***





*** Variables ***
# FRA04 DE Site
#${master_username}   root
#${ABR-01}    172.24.70.16
#${ABR-02}    172.24.70.17
#${ABR-03}    172.24.70.18
#${ABR-04}    172.24.70.19
#${RSX-01}    172.24.70.51
#${RSX-02}    172.24.70.52
#${RSX-03}    172.24.70.53
#${RSX-04}    172.24.70.54
#${AAA-01}    172.24.70.34
#${AAA-02}    172.24.70.35
#${XEPA-01}    172.24.70.28
#${XEPA-02}    172.24.70.29
#${WCS-01}    172.24.69.35
#${WCS-02} 	 172.24.69.36
#${UE-Simulator}     172.24.70.36
#${DE_PASSWORD}    crypt:QQ43MvbD6tbGZvupmbxJxWgjgb6J/+/x3r7l1NN4eGtpnfFQb9s39I6T3d39e/iiGkHog68upn9t+wRPQw==
#${website_name}    google.com
#${Int_Name}    ens192
#${FRA08-AAA-Simulator}    172.24.67.33
#${Radius_FRA08_Message_execution_ABR56}   ip netns exec AAA56  ./testapex_working -D -cfg cfg_examples/cfg_de_AAASim_a10.yml  -scn a1_dummy_simulator_device.xml



# APN Health Check DE Site
${master_username}   root
${ABR5-FRA08-IP}    172.24.67.40
${ABR6-FRA08-IP}    172.24.67.41
${fra08_password}    crypt:YpebdMn5TFu8enqcq4hfJnwjOVww46VgNR0rOp8MnFUy05Z6bh4HlBkf91hhSD00DzyOmz3mlcCurmdz
${DE_PASSWORD}    crypt:Htu4feizFaaKkac31eybWb8FHLzh6DUMpBcY7E2PF1N/aJFu6RejChnXJJ5bLY1z+QCsdFvf58ZdzARP
${DE_PASSWORD_PAR01}    crypt:P2dJS77gzjjBSAl9nSBMSiqnugDGEIQSOCJfkt4GzBGVCleS6u1+t7bA0c0qpuPQOODHc7CPOm+yUg3A
${website_name}    google.com
${Int_Name}    ens192
${APN-Health-Check-Simulator}    172.24.70.70
${APN-Health-Check-PAR01}    172.24.61.6
${root_username}    root
${Radius_APN_Health_Check_Message_execution}    ip vrf exec vrf-naname-A10 ./testapex_working -D -cfg cfg_examples/cfg_de_AAASim_a10.yml -scn E2E_scenario_a1.xml
${Radius_Execution}    ip vrf exec vrf-A10-A11 ./testapex_working -D -cfg cfg_examples/cfg_de_AAASim_a10.yml -scn E2E_scenario_a1.xml
${UE_browse_traffic}    ip vrf exec vrf-naname-A10  curl --interface 10.169.0.8 --dns-ipv4-addr 10.169.0.8 https://cisco.com -v
${UE_traffic}    ip vrf exec vrf-A10-A11  curl --interface 10.169.0.4 --dns-ipv4-addr 10.169.0.4 https://cisco.com -v
${br_address}    ip -br addr