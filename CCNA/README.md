# 🛡️ CCNA & Windows System Administrator Troubleshooting & Command Reference Handbook
This handbook is designed as a practical, real-world production reference guide for Help Desk T1/T2, System Administrators, and Junior Network Administrators. It provides a structured troubleshooting methodology categorized strictly by the OSI model.

---

# 🏢 Layer 1: Physical Layer

### Protocol Overview
The Physical Layer (Layer 1) deals with the physical transmission of signals (electrical, optical, or radio) over a physical medium. In enterprise environments, this consists of copper cabling (Cat5e/Cat6/Cat6A), fiber optics (single-mode/multi-mode), SFP/SFP+ transceivers, and Power over Ethernet (PoE). Physical layer issues are the root cause of many network anomalies, including interface flapping, low throughput, packet loss, and power failures on remote devices (APs, VoIP phones).

### Core Commands
#### Windows PowerShell
* `Get-NetAdapter` - Check status (Up/Down), interface name, and driver details of all network adapters.
* `Get-NetAdapter | ft Name, Status, LinkSpeed` - Verify interface speed negotiation (e.g., 1 Gbps vs 100 Mbps) to detect speed degradation.
* `Get-NetAdapterStatistics` - Check error counters, discarded packets, and packet counts on local interfaces.
* `Get-NetAdapterAdvancedProperty` - Inspect low-level NIC configurations (e.g., Speed & Duplex, Energy Efficient Ethernet, Jumbo Frames).
* `Get-PnpDevice -Class Net` - Verify network adapter hardware status in Device Manager to detect driver failures or hardware malfunction.
* `Disable-NetAdapter -Name "Ethernet"` - Disable a specific local network adapter to force a hardware/driver reset during troubleshooting.
* `Enable-NetAdapter -Name "Ethernet"` - Re-enable a local network adapter after a reset.

#### Cisco IOS CLI
* `show interfaces` - Inspect physical interface status, duplex, speed, and error counters (CRC, frame errors, collisions).
* `show interfaces status` - Get a summary of port status (connected, notconnect, err-disabled), speed, and duplex.
* `show interfaces counters errors` - Display CRC errors, input/output errors, collisions, giants, and runts on all ports.
* `show interfaces transceiver` - Measure optical SFP Rx/Tx power levels, temperature, and current to check fiber link quality.
* `show power inline` - Monitor PoE power allocation, consumption, and class for connected devices (VoIP phones, APs).
* `show inventory` - List switch chassis modules, serial numbers, and installed SFP transceiver details.
* `show logging` - Check the system log buffer for link up/down (flapping) events and port status changes.

---

### Common Incidents
* **Physical Link Down**: Interface shows "notconnect" (Cisco) or "Disconnected" (Windows). Caused by unplugged cables, faulty patch cords, dead network cards, or disabled switch ports.
* **Intermittent Packet Loss & High Latency (CRC Errors)**: Cable runs exceeding 100 meters, damaged copper runs, or dirty optical fibers causing signal attenuation and frame corruption.
* **PoE Device Failures / Boot Looping**: A VoIP phone or Access Point boot loops because the switch has exceeded its PoE power budget or the cable has excessive resistance.
* **SFP Transceiver Failure**: Optics link fails due to incompatible/unsupported SFP modules, dirty fiber end-faces, or defective lasers.

---

### Troubleshooting Workflow
1. **Verify Physical Status**: Inspect link lights on the network interface card (NIC) and the switch port. Run `Get-NetAdapter` on the host and `show interfaces status` on the switch.
2. **Isolate Cabling/Hardware**: Swap the patch cable at both ends. Connect the client to a different wall jack or switch port.
3. **Analyze Errors**: If the link is up but performance is poor, run `show interfaces counters errors` on the switch.
   * **CRC / Input Errors**: High CRC counts usually mean dirty fiber, damaged copper cabling, or external electromagnetic interference (EMI).
   * **Late Collisions**: Usually indicates a duplex mismatch (e.g., one side hardcoded to Full Duplex, the other set to Auto).
4. **Test Optics**: For fiber connections, run `show interfaces transceiver`. Ensure the Rx optical power is within the specified operational range (typically -3 dBm to -15 dBm).
5. **Check PoE Allocation**: If a PoE device fails to power on, run `show power inline` to check the switch's remaining power budget and the port's PoE class.

---

### Real-World Best Practices
* **Enforce Auto-Negotiation**: Always leave speed and duplex settings on auto-negotiation. Hardcoding one side causes duplex mismatches.
* **Label Infrastructure**: Adhere to a strict labeling convention for patch panels, wall jacks, and switch ports.
* **Keep Fiber Clean**: Always clean fiber optic connectors with specialized cleaning tools before inserting them into SFP ports.
* **Disable Unused Ports**: Keep unused switch ports administratively shut down (`shutdown`) to enhance security.

---

# ➕ Layer 2: Data Link Layer

### Protocol Overview
The Data Link Layer (Layer 2) is responsible for node-to-node data transfer, framing, and physical addressing (MAC). It manages local area network (LAN) topologies using protocols like Ethernet, ARP, Spanning Tree Protocol (STP), VLAN tagging (802.1Q), link aggregation (EtherChannel/LACP), and device discovery (CDP/LLDP).

---

## 1. Ethernet & MAC Addresses
### Core Commands
#### Windows
* `getmac /v` - Display the MAC addresses of all network adapters with connection details.
* `ipconfig /all` - View the Physical Address (MAC) alongside all IP configurations.
* `Get-NetAdapter | select Name, MacAddress, Status` - Retrieve a clean table of adapter names, MAC addresses, and operational status.
#### Cisco IOS CLI
* `show mac address-table` - Display the dynamic and static MAC address-to-port mapping table on the switch.
* `show mac address-table interface <port>` - Verify which MAC addresses are learned on a specific physical port.
* `show mac address-table | include <MAC>` - Locate the switch port where a specific MAC address is active.
* `clear mac address-table dynamic` - Flush all dynamically learned MAC addresses to force immediate table rebuilding.

### Common Incidents
* **MAC Address Flapping**: The same MAC address is learned on two different ports in rapid succession, resulting in severe packet loss and connection drops. Usually caused by a physical network loop or duplicate MACs.

### Troubleshooting Workflow
1. Trace the physical path of a device by looking up its MAC address. Run `show mac address-table | include <MAC>` on the access switch.
2. If the MAC is learned on a trunk port, trace it to the upstream switch until the access port is identified.
3. Check the switch logs (`show logging`) for "MAC Flapping" messages. Identify the two ports involved and check if they represent redundant connections without STP.

### Real-World Best Practices
* **Monitor MAC Table Size**: Watch out for MAC Flooding attacks. Set up MAC address-limit thresholds if supported by the switch.

---

## 2. ARP (Address Resolution Protocol)
### Core Commands
#### Windows
* `arp -a` - Display the local ARP cache containing resolved IPv4-to-MAC address mappings.
* `arp -d *` - Flush the host's ARP cache to resolve stale or incorrect mappings (requires Admin).
* `Get-NetNeighbor` - View the local IPv4/IPv6 neighbor cache in PowerShell.
* `Remove-NetNeighbor` - Clear the PowerShell neighbor cache to force new address resolution.
#### Cisco IOS CLI
* `show arp` - Display the router or Layer 3 switch ARP table.
* `clear arp-cache` - Clear the router's ARP table to resolve stale MAC-to-IP associations.

### Common Incidents
* **Stale ARP Cache**: A network device (e.g., a printer or server) is replaced, keeping its IP but getting a new MAC. Other hosts fail to connect because they send traffic to the old MAC.
* **IP Address Conflict**: Two hosts are manually configured with the same IP address, causing intermittent connectivity as the ARP table flaps between their MACs.

### Troubleshooting Workflow
1. Ping the target host. If it fails, run `arp -a` (Windows) or `show arp` (Cisco) to check the mapped MAC address for that IP.
2. Compare the mapped MAC with the physical MAC on the target device.
3. If the MAC addresses differ, delete the stale ARP entry on the client (`arp -d <IP>`) or the router (`clear arp-cache`), and ping again.
4. If an IP conflict is suspected, disconnect the primary device and ping the IP. If it still responds, look up the active MAC address in the ARP cache to identify the rogue device.

### Real-World Best Practices
* **Enable Dynamic ARP Inspection (DAI)**: Use DAI on enterprise switches to validate ARP packets against DHCP snooping databases, protecting against ARP poisoning and spoofing attacks.

---

## 3. VLANs & Trunking (Access & Trunk Ports)
### Core Commands
#### Cisco IOS CLI
* `show vlan brief` - List all configured VLANs and the access ports assigned to them.
* `show interfaces trunk` - View active trunk links, native VLAN configurations, and allowed VLAN lists.
* `show interfaces <port> switchport` - Inspect the administrative and operational switchport configuration (access/trunk/native).

### Common Incidents
* **Access Port in Wrong VLAN**: A user device is placed in the wrong broadcast domain (e.g., VoIP phone in guest VLAN), blocking access to corporate servers or resources.
* **Trunk VLAN Pruning Issue**: A newly created VLAN is not permitted on trunk ports between switches, causing traffic for that VLAN to drop at the boundary.
* **Native VLAN Mismatch**: The native (untagged) VLAN differs on two ends of a trunk link, causing traffic leakage between VLANs and STP anomalies.

### Troubleshooting Workflow
1. Determine the user's switch port. Run `show vlan brief` to verify if the port is assigned to the correct VLAN.
2. If traffic fails to reach other switches, run `show interfaces trunk` on both trunk endpoints.
3. Ensure the VLAN in question is listed under "VLANs allowed and active in management domain". If missing, update the allowed list using `switchport trunk allowed vlan add <vlan_id>`.
4. Check for Native VLAN mismatches in switch logs (`show logging`). If mismatched, configure the correct native VLAN on both sides (`switchport trunk native vlan <vlan_id>`).

### Real-World Best Practices
* **Avoid Default VLAN 1**: Do not use VLAN 1 for user traffic or device management. Standardize on dedicated VLANs (e.g., VLAN 10 for Data, 20 for Voice, 99 for Management).
* **Explicit Trunk Configuration**: Never leave trunk links open to all VLANs. Manually prune trunks using `switchport trunk allowed vlan`.

---

## 4. Spanning Tree Protocol (STP & RSTP)
### Core Commands
#### Cisco IOS CLI
* `show spanning-tree` - View the active Spanning Tree topology, root bridge parameters, and port roles/states.
* `show spanning-tree vlan <id>` - Inspect Spanning Tree state for a specific VLAN.
* `show spanning-tree interface <port>` - Verify the STP role (root, designated, alternate) and state (forwarding, blocking) of a specific port.

### Common Incidents
* **STP Broadcast Storm (Loop)**: A network loop is formed (e.g., dual-connected switches without STP, or a user loops a cable back into a wall outlet). The resulting broadcast storm pegs switch CPUs to 100% and crashes the network.
* **Slow DHCP / Link Up Delay**: A PC takes 30-50 seconds to obtain an IP address when plugged in. This occurs because the switch port transitions through full STP states (listening, learning) before forwarding.

### Troubleshooting Workflow
1. If network performance collapses and switch link lights flash rapidly, run `show processes cpu sorted` on the core switch to check for high CPU utilization.
2. Run `show spanning-tree detail | include changes` to verify if topology changes are constantly occurring.
3. Run `show spanning-tree` to locate the Root Bridge and trace the blocking ports. If a loop is active, locate the port receiving high broadcast rates and shut it down.
4. If a client is slow to connect, check if the switch port has PortFast enabled. Run `show spanning-tree interface <port>`.

### Real-World Best Practices
* **Configure PortFast & BPDU Guard**: Always configure `spanning-tree portfast` and `spanning-tree bpduguard enable` on all edge/access ports to prevent loops from user-connected switches.
* **Designate the Root Bridge**: Explicitly set primary and secondary root bridges using priority values (`spanning-tree vlan <id> priority 4096`) instead of leaving it to default elections.

---

## 5. EtherChannel (LACP & PAgP)
### Core Commands
#### Cisco IOS CLI
* `show etherchannel summary` - Check the status of all port channels (logical links) and member ports.
* `show etherchannel port-channel` - Review detailed protocol and state information for logical channels.
* `show interfaces port-channel <num>` - Verify the logical interface's speed, duplex, and overall link status.

### Common Incidents
* **EtherChannel Mismatch (Down Link)**: One switch is configured with active negotiation (LACP), and the other is set to static `on`, causing the bundle to fail and ports to enter an err-disabled state.
* **Member Port Configuration Drift**: Individual physical ports within the EtherChannel have different speed, duplex, or VLAN settings, preventing them from joining the bundle.

### Troubleshooting Workflow
1. Run `show etherchannel summary`. Verify if the channel status is `SU` (Layer 2 - Up) or `SD` (Layer 2 - Down).
2. Check the port flags: `P` means the port is bundled and operational; `I` means the port is acting as a stand-alone interface due to negotiation failure.
3. Inspect both switch configurations to ensure the channel-group mode matches (e.g., `active` on both ends, or `active` and `passive`).
4. Ensure all physical member ports have identical configurations (speed, duplex, trunk status, allowed VLANs).

### Real-World Best Practices
* **Use LACP exclusively**: Standardize on LACP (`mode active`) for link aggregation. Avoid Cisco-proprietary PAgP and static `mode on` configurations.

---

## 6. Discovery Protocols (CDP & LLDP)
### Core Commands
#### Cisco IOS CLI
* `show cdp neighbors` - List directly connected Cisco devices, their local/remote interfaces, and device types.
* `show cdp neighbors detail` - View the IP addresses, software versions, and hardware platforms of neighboring Cisco devices.
* `show lldp neighbors` - List directly connected multi-vendor devices (e.g., HP/Aruba switches, VoIP phones, APs).
* `show lldp neighbors detail` - View detailed vendor neighbor information, including management IP addresses.

### Common Incidents
* **Lack of Topology Visibility**: Troubleshooting a remote site without network maps or documentation.
* **IP Phone VLAN Discovery Failure**: A VoIP phone fails to join the voice VLAN because discovery protocols are disabled on the switch port.

### Troubleshooting Workflow
1. SSH into the switch and run `show cdp neighbors` or `show lldp neighbors` to map the physical layout.
2. If an IP phone fails to register, run `show lldp neighbors detail` to verify that the switch is advertising the voice VLAN ID to the phone.

### Real-World Best Practices
* **Secure External Interfaces**: Disable CDP and LLDP (`no cdp run`, `no lldp run`) on external or public-facing interfaces to prevent unauthorized information disclosure.

---

## 7. Port Security
### Core Commands
#### Cisco IOS CLI
* `show port-security` - View general port security status across all switch interfaces.
* `show port-security interface <port>` - Verify port security state, violation counter, and configured actions (shutdown, restrict, protect) on a port.
* `show port-security address` - List all secure MAC addresses learned in the system.

### Common Incidents
* **Port Err-Disabled (Security Violation)**: A user plugs a non-authorized device or an unmanaged switch into an access port, exceeding the maximum allowed MAC count and triggering a port shutdown.

### Troubleshooting Workflow
1. Run `show interfaces status` to find ports in the `err-disabled` state.
2. Run `show port-security interface <port>` to check the violation counter and confirm if a security violation occurred.
3. Identify the unauthorized MAC address using `show port-security address`.
4. Resolve by disconnecting the rogue device and resetting the port: run `shutdown` followed by `no shutdown` on the interface.

### Real-World Best Practices
* **Use Restrict Mode**: Use `restrict` mode (`switchport port-security violation restrict`) to drop unauthorized traffic and generate syslog alerts without completely shutting down the physical port.
* **Implement Errdisable Recovery**: Configure `errdisable recovery cause psecure-violation` to automatically re-enable ports after a timeout (e.g., 300 seconds).

---

# 🌐 Layer 3: Network Layer

### Protocol Overview
The Network Layer (Layer 3) handles logical addressing, packet routing, and path determination across subnets. The core protocols are IPv4 and IPv6, supported by routing tables, routing protocols (OSPF), diagnostic utilities (ICMP, Traceroute), address translation (NAT), and secure tunneling (VPN).

---

## 1. IPv4, IPv6 & Subnetting
### Core Commands
#### Windows
* `ipconfig` - Display basic IP address, subnet mask, and default gateway configurations.
* `ipconfig /all` - Show full IP details, including lease times, DHCP servers, and DNS configurations.
* `Get-NetIPAddress` - Retrieve detailed IPv4/IPv6 configurations in PowerShell.
* `Test-Connection` - Ping a destination IP to verify basic network-layer reachability.
#### Cisco IOS CLI
* `show ip interface brief` - View the status (up/up) and IPv4 addresses of all switch/router interfaces.
* `show ipv6 interface brief` - View the status and IPv6 addresses of all interfaces.
* `show ip interface` - Inspect detailed IP properties and helper addresses on an interface.

### Common Incidents
* **IP Address Conflict**: Two devices are assigned the same IP, causing intermittent connectivity for both as routers flap traffic between destinations.
* **APIPA (169.254.x.x) Address**: A Windows client fails to receive a DHCP response and auto-assigns an APIPA address, losing communication with the rest of the corporate network.
* **Subnet Mask Mismatch**: A host is configured with an incorrect subnet mask (e.g., /24 instead of /23), making it unable to communicate with hosts in the same logical subnet.

### Troubleshooting Workflow
1. Run `ipconfig` on the affected host. If the IP is `169.254.x.x`, troubleshoot Layer 2 connectivity, DHCP server availability, or DHCP scope exhaustion.
2. If an IP conflict is reported, disconnect the affected host and run `ping` from another device. If it replies, run `arp -a` to get the MAC address of the conflicting device.
3. Verify that the subnet mask and default gateway match the official network allocation documentation.

### Real-World Best Practices
* **Use IPAM**: Maintain an IP Address Management (IPAM) tool to track static IP allocations and avoid manual sheet-based tracking.
* **Leverage DHCP Reservations**: For servers or printers that need static IPs, use DHCP reservations instead of manual on-device configuration when possible to centralize management.

---

## 2. Default Gateway & Routing (Static Routes, OSPF)
### Core Commands
#### Windows
* `route print` - Display the host's active IPv4 and IPv6 routing tables.
* `route add <net> mask <mask> <gw>` - Add a static route to direct traffic to a specific gateway.
* `Get-NetRoute` - View and manage the host routing table via PowerShell.
#### Cisco IOS CLI
* `show ip route` - Display the router's current routing table.
* `show ip route static` - View only manually configured static routes.
* `show ip ospf neighbor` - Check OSPF neighbor relationships, states (e.g., FULL), and interface associations.
* `show ip ospf interface` - Verify OSPF hello/dead intervals, area IDs, and MTU values.

### Common Incidents
* **Unreachable Default Gateway**: The host is configured with the wrong gateway IP or the gateway interface is down, preventing communication outside the local subnet.
* **Routing Loop**: Misconfigured static routes or dynamic routing policies cause packets to loop between routers until TTL expires, resulting in packet drops.
* **OSPF Adjacency Failures**: OSPF fails to form neighbors (remaining in INIT, 2-WAY, or EXSTART states) due to mismatched MTUs, subnet masks, hello/dead timers, or area IDs.

### Troubleshooting Workflow
1. Ping the default gateway from the host. If successful, local Layer 3 is functioning.
2. Run `route print` (Windows) or `show ip route` (Cisco) to verify that a route exists for the destination network. Look for the default route (`0.0.0.0/0`).
3. If OSPF neighbors are not forming, run `show ip ospf neighbor`.
   * Stuck in `2-WAY`: Normal for DROTHER switches on multi-access links, but indicates an issue if it occurs between routers expected to peer fully.
   * Stuck in `EXSTART/EXCHANGE`: Check for an MTU mismatch between the interfaces (`ip mtu` must match).
4. Verify that Hello/Dead timers match on both ends (`show ip ospf interface`).

### Real-World Best Practices
* **Minimize Static Routes**: Use dynamic routing protocols (like OSPF) in enterprise networks to auto-adjust to link failures. Use static routes only for simple stub networks.
* **Default Route Aggregation**: Point a single default static route (`0.0.0.0/0`) from access/distribution switches to the core or firewall.

---

## 3. ICMP & Path Diagnostics (Ping, Traceroute, Pathping)
### Core Commands
#### Windows
* `ping <host> -t` - Run a continuous ping to monitor connection stability or device boot cycles.
* `tracert <host>` - Trace the path packets take to a destination, listing each router hop.
* `pathping <host>` - Analyze network paths over several minutes, calculating packet loss at each router hop.
#### Cisco IOS CLI
* `ping <ip>` - Run a basic ICMP echo test to check destination reachability.
* `ping ip <ip> source <int>` - Perform an extended ping using a specific source interface to test routing and VPN tunnel functionality.
* `traceroute <ip>` - Trace the network path to a destination IP.

### Common Incidents
* **Intermittent WAN Packet Loss**: Latency spikes and packet drops affecting applications across site-to-site WAN connections.
* **Firewall Blocking ICMP**: A server is hosting active services but appears "offline" because a host-based firewall blocks ICMP echo requests.

### Troubleshooting Workflow
1. Run continuous `ping -t` to check if packet loss is constant or intermittent.
2. Run `tracert <destination_IP>` to identify which router hop along the path is introducing latency or failing.
3. Run `pathping <destination_IP>` to pinpoint the exact hop experiencing packet loss over time.
4. If a ping fails to a server, verify if specific application ports are accessible (e.g., using TCP checks) before assuming the server is offline.

### Real-World Best Practices
* **Do Not Disable ICMP Internally**: Keep ICMP enabled within the corporate firewall boundaries to facilitate troubleshooting. Block it only at the public-facing edge.

---

## 4. NAT (Network Address Translation)
### Core Commands
#### Cisco IOS CLI
* `show ip nat translations` - View active inside-to-outside address translation mappings on the router.
* `show ip nat statistics` - Check NAT configuration parameters, translation hits, and active pool capacity.
* `clear ip nat translation *` - Clear all dynamic translation entries.
#### FortiGate
* `diagnose sys session list` - Display the active session table showing NAT and port translations.

### Common Incidents
* **NAT IP Pool Exhaustion**: Internal hosts fail to connect to the Internet because all available public IPs in the NAT pool are allocated.
* **Static NAT Port Mapping Failures**: Port forwarding rules fail, blocking external access to internal web or application servers.

### Troubleshooting Workflow
1. Check NAT statistics (`show ip nat statistics`) to see if the translation limits or pool allocations are exhausted.
2. Verify that interfaces are correctly assigned: `ip nat inside` on the LAN-facing interface and `ip nat outside` on the WAN-facing interface.
3. Run `show ip nat translations | include <internal_ip>` to verify if a translation is active for the affected device.

### Real-World Best Practices
* **Use PAT (NAT Overload)**: Implement Port Address Translation (PAT) rather than static 1-to-1 NAT pools for general user internet egress, allowing thousands of hosts to share a single public IP.

---

## 5. VPN (IPsec, GRE, WireGuard, L2TP)
### Core Commands
#### Cisco IOS CLI
* `show crypto isakmp sa` - Check the status of Phase 1 (IKE) tunnels (should be active and in `QM_IDLE` state).
* `show crypto ipsec sa` - View Phase 2 (IPsec) tunnel details, verifying encrypt/decrypt packet counters.
* `show crypto session` - Display a consolidated summary of active cryptographic sessions.
#### FortiGate
* `get vpn ipsec tunnel details` - Verify the status, selectors, and encryption stats of IPsec tunnels.

### Common Incidents
* **VPN Tunnel Fails to Establish**: The tunnel does not come up due to mismatched pre-shared keys (PSKs), mismatched encryption/hashing standards, or blocked UDP ports.
* **One-Way Traffic on VPN**: Traffic only flows in one direction. Usually caused by routing issues on one end or firewalls blocking the return path.

### Troubleshooting Workflow
1. Run `show crypto isakmp sa` (Cisco) or equivalent. If empty or in an error state, Phase 1 has failed. Check Phase 1 parameters (DH Group, encryption, hash, PSK).
2. If Phase 1 is up, run `show crypto ipsec sa`. Check the packet counters:
   * **#pkts encaps** is incrementing, but **#pkts decaps** is 0: The local side is sending traffic, but the remote side is either not receiving it or its response is failing. Check NAT-Traversal (NAT-T, UDP 4500) and firewalls.
3. Ensure the security policy's "interesting traffic" ACLs match exactly on both endpoints.

### Real-World Best Practices
* **Enable DPD**: Implement Dead Peer Detection (DPD) to clean up stale VPN states and automatically re-initiate tunnels upon failure.
* **Use Modern Cryptography**: Standardize on AES-256 and SHA-256 for encryption and hashing, with Diffie-Hellman Group 14 or higher. Avoid DES, 3DES, and MD5.

---

## 6. DHCP Relay (IP Helper)
### Core Commands
#### Cisco IOS CLI
* `show ip interface <VLAN_interface>` - Verify if `Helper address` is configured and pointing to the correct DHCP server.
* `show ip route <DHCP_server_IP>` - Confirm that the router has a valid route to the subnet where the DHCP server resides.

### Common Incidents
* **DHCP Address Request Timeout**: Clients in a VLAN cannot obtain IP addresses and fall back to APIPA, because the local router is not forwarding the broadcast DHCP requests to the centralized DHCP server.

### Troubleshooting Workflow
1. Access the default gateway (VLAN interface) on the switch/router. Run `show ip interface vlan <vlan_id>`.
2. Verify that the command `ip helper-address <DHCP_server_IP>` is configured.
3. Ping the DHCP server from the switch using the VLAN interface as the source: `ping <DHCP_server_IP> source <VLAN_IP>`. If this fails, resolve the routing path between the switch and the DHCP server.
4. Check the DHCP server logs to verify if DHCP Discover packets from the relay IP are arriving.

### Real-World Best Practices
* **Redundant Helpers**: If using primary and secondary DHCP servers, configure two `ip helper-address` commands on the interface to point to both servers.

---

# ⚡ Layer 4: Transport Layer

### Protocol Overview
The Transport Layer (Layer 4) manages end-to-end communication, flow control, and multiplexing using TCP (reliable, connection-oriented) and UDP (unreliable, connectionless). It identifies target services using port numbers (0 - 65535). Troubleshooting at this layer involves verifying port accessibility, checking active connection states, and identifying port depletion issues.

### Core Commands
#### Windows
* `netstat -ano` - List all active TCP/UDP connections, listening ports, and associated Process IDs (PIDs).
* `Test-NetConnection -ComputerName <host> -Port <port>` - Verify if a specific TCP port is open and reachable on a remote host (essential firewall check).
* `Get-NetTCPConnection` - Show detailed state information (Listen, Established, TimeWait) for TCP connections in PowerShell.
* `Get-NetUDPEndpoint` - Show active UDP listeners in PowerShell.
#### FortiGate
* `diagnose sys session list | grep <port>` - Inspect the active firewall session table for a specific port to check if traffic is being permitted or dropped.

---

### Common Incidents
* **TCP Port Blocked (Firewall Rule)**: The client tries to connect, but the connection times out because a network or host-based firewall drops the SYN packets.
* **Service Crash (Connection Refused)**: The client receives a TCP Reset (RST) packet immediately, indicating the target server is reachable but the application service is not running or listening.
* **Ephemeral Port Exhaustion**: A server handles too many outbound or short-lived connections and runs out of available ports (default Windows range: 49152-65535), blocking new connection attempts.

---

### Troubleshooting Workflow
1. On the target server, verify if the application is running and listening: run `netstat -ano | findstr <port>`.
2. Identify the process ID (PID) from the output and verify that it matches the correct service in Task Manager or Services.
3. From the client machine, test connectivity using `Test-NetConnection -ComputerName <Server_IP> -Port <Port>`.
   * **TcpTestSucceeded : True**: The network path is clear, and the service is responding.
   * **TcpTestSucceeded : False (with timeout)**: A firewall is likely dropping the traffic. Check local Windows Defender Firewall and intermediate network firewalls.
   * **TcpTestSucceeded : False (with immediate failure/connection refused)**: The service is not running on the server, or a security appliance is actively sending a TCP RST.
4. To check for port exhaustion on a server, run `Get-NetTCPConnection` and verify if thousands of ports are stuck in the `TIME_WAIT` state.

---

### Real-World Best Practices
* **Use Port Checks Over Ping**: Never rely on ping alone to verify service availability. Servers often block ICMP but permit application ports, or vice versa. Always use `Test-NetConnection`.
* **Adjust Ephemeral Port Ranges**: For high-traffic database or web servers, monitor and adjust ephemeral port settings and TCP connection timeouts if port exhaustion is detected.

---

# 🌐 Layers 5-7: Session, Presentation & Application Layers

### Protocol Overview
These layers handle application logic, data formatting, and session synchronization. In corporate Windows environments, these layers are dominated by DNS (domain resolution), DHCP (automatic IP provisioning), Active Directory (LDAP/Kerberos authentication), SMB (file sharing), RDP (remote desktop access), Citrix (virtual app delivery), and SSL VPN (secure web access).

### Core Commands
#### Windows Command Line & PowerShell
* `nslookup <domain>` - Query DNS servers to verify domain name resolution and check record availability.
* `Resolve-DnsName <domain>` - Resolve hostnames via PowerShell, returning detailed DNS record objects.
* `ipconfig /flushdns` - Clear the client's local DNS resolver cache to remove stale or poisoned records.
* `ipconfig /registerdns` - Force the client to update its host (A) and pointer (PTR) records on the Active Directory DNS server.
* `klist purge` - Clear local Kerberos tickets to force re-authentication (useful for group membership updates).
* `nltest /dsgetdc:<domain>` - Query which domain controller the client is currently using for authentication.
* `nltest /sc_verify:<domain>` - Verify the secure channel connection between the client workstation and the Domain Controller.
* `dcdiag` - Run diagnostic health checks on Active Directory Domain Controllers (requires DC admin).
* `gpupdate /force` - Pull and apply the latest Group Policy Objects (GPOs) from the Domain Controller immediately.
* `gpresult /h gpreport.html` - Generate a comprehensive HTML report of all applied Group Policies.
* `net share` - List all active SMB shares and directory paths on the local computer.
* `w32tm /query /status` - Inspect the system's time synchronization source and status (critical for Kerberos).
#### Cisco IOS CLI
* `show ip dhcp binding` - Display active IP address leases issued by the switch/router DHCP server.

---

### Common Incidents
* **DNS Resolution Failure**: Users cannot access internal resources or websites because client DNS settings are incorrect or the DNS server is down.
* **DHCP Scope Exhaustion**: No IP addresses are left in the DHCP scope pool. Clients fall back to APIPA (169.254.x.x) and lose network connectivity.
* **Active Directory Secure Channel Failure**: The trust relationship between the workstation and the domain controller is broken, preventing user logins.
* **Kerberos Time Skew**: Workstations cannot log in or access shares because their system clock differs from the Domain Controller's clock by more than 5 minutes.
* **SMB Access Denied**: File shares are inaccessible due to mismatched Share and NTFS permissions, or because SMBv1 is disabled on the server.
* **RDP Connection Rejected**: Remote Desktop access fails because NLA (Network Level Authentication) blocks the client, or the RDP port (3389) is blocked.
* **Citrix VDA Registration Failure**: Virtual Delivery Agents (VDAs) fail to register with Delivery Controllers, blocking user virtual desktop launches.
* **SSL VPN Authentication Failures**: Users cannot connect to the VPN because the SSL/TLS gateway certificate has expired or the client lacks proper cipher support.

---

### Troubleshooting Workflow
#### For DNS Failures
1. Run `Resolve-DnsName <target_domain>`. If it fails, check the client's configured DNS servers using `ipconfig /all`.
2. Test a public resolver: `Resolve-DnsName -Name <target_domain> -Server 8.8.8.8`. If this succeeds, the issue is with the local internal DNS servers.
3. Flush the local cache: `ipconfig /flushdns`.

#### For Active Directory / Kerberos Login Failures
1. Check the local clock. If it differs from the Domain Controller, run `w32tm /config /syncfromflags:domhier /update` followed by `w32tm /resync` to align time.
2. Verify the AD trust relationship: run `nltest /sc_verify:<domain>`.
3. If the trust is broken, run `Reset-ComputerMachinePassword` in PowerShell or re-join the client to the domain.

#### For DHCP Scope Issues
1. On the DHCP server, check scope statistics.
2. If the scope is full, reduce the lease duration (e.g., from 8 days to 24 hours for wireless networks) or expand the IP address range.
3. On the client, force a release and renewal: `ipconfig /release` followed by `ipconfig /renew`.

#### For SMB File Share Failures
1. Verify network path availability: `Test-NetConnection -ComputerName <Server_IP> -Port 445`.
2. Inspect the Share permissions (configured in the sharing tab) and NTFS permissions (configured in the security tab). The most restrictive permission always wins.
3. Ensure the server does not require SMBv1 if the client only supports newer versions.

#### For RDP Failures
1. Verify that RDP is enabled on the target system: run `Get-Service -Name TermService` and check that the status is running.
2. Verify if the target port (3389) is open: `Test-NetConnection -ComputerName <Server_IP> -Port 3389`.
3. If connecting from a non-domain machine, temporarily disable Network Level Authentication (NLA) on the server if NLA is blocking connection, or ensure the user is added to the "Remote Desktop Users" group.

#### For Citrix VDA Failures
1. Verify that the VDA can resolve the Delivery Controller's FQDN.
2. Verify TCP port connectivity to the Delivery Controller (ports 80, 443, 1494, 2598, and 8082).

#### For SSL VPN Failures
1. Access the VPN gateway URL via browser to inspect the certificate validity and expiry date.
2. Verify TLS client protocol compatibility on the user's browser/client software.

---

### Real-World Best Practices
* **Standardize on AD-Integrated DNS**: Always configure domain-joined clients to use Active Directory-integrated DNS servers exclusively. Never mix internal and external DNS servers on client NICs.
* **Implement DHCP Failover**: Set up Windows Server DHCP Failover in Hot Standby or Load Balance mode to ensure continuous IP availability.
* **Disable SMBv1**: Turn off SMBv1 domain-wide to prevent ransomware lateral movement. Enforce SMBv2 or SMBv3.
* **Secure RDP via GPO**: Always enforce Network Level Authentication (NLA) and restrict RDP access to authorized groups via Group Policy.
* **Configure Time Sync (NTP)**: Ensure the PDC Emulator role in your Active Directory domain synchronizes with a reliable external NTP source, and all domain members sync from the domain hierarchy.
