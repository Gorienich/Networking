# Networking Lab

A practical networking and security laboratory focused on real-world troubleshooting, infrastructure operations, network monitoring, automation, and enterprise technologies.

This repository combines hands-on labs, production-inspired investigations, PowerShell tooling, monitoring workflows, security research, and operational runbooks.

Topics range from CCNA fundamentals through CCNP/CCIE-level troubleshooting, including Cisco, FortiGate, Citrix, VPNs, VoIP, network security, and penetration testing.

---

## Learning Resources

### Networking

* https://roadmap.sh/network-engineer
* https://learningnetwork.cisco.com
* https://www.gns3.com
* https://www.eve-ng.net
* https://www.wireshark.org

### Security

* https://owasp.org
* https://attack.mitre.org
* https://csrc.nist.gov
* https://pentest-tools.com
* https://www.pentest-standard.org

### Virtualization & Labs

* https://www.vmware.com
* https://www.virtualbox.org
* https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server

---

## Purpose

This repository serves as a centralized knowledge base for:

* Network Troubleshooting
* Infrastructure Diagnostics
* Connectivity Monitoring
* Performance Analysis
* Routing & Switching
* Firewall Administration
* VPN Technologies
* Citrix Environments
* VoIP Infrastructure
* Security Assessments
* Automation & Scripting
* Incident Investigation
* Operational Runbooks

The goal is to document practical solutions, reusable tools, and proven troubleshooting methodologies based on real-world environments rather than theoretical examples.

---

## Repository Structure

```text
Networking/
│
├── Fundamentals/
│   ├── OSI
│   ├── TCP-IP
│   ├── IPv4
│   ├── IPv6
│   └── Subnetting
│
├── Routing-Switching/
│   ├── VLANs
│   ├── STP
│   ├── OSPF
│   ├── BGP
│   └── MPLS
│
├── Firewalls/
│   ├── FortiGate
│   ├── NAT
│   ├── Policies
│   └── VPN
│
├── Citrix/
│
├── VoIP/
│
├── Monitoring/
│
├── Automation/
│
├── Security/
│
└── Documentation/
```

---

## Network Lab Platforms

| Platform                 | Difficulty   | Primary Use Case                        | Recommended Level |
| ------------------------ | ------------ | --------------------------------------- | ----------------- |
| Cisco Packet Tracer      | Beginner     | Networking fundamentals                 | CCNA              |
| GNS3                     | Intermediate | Real Cisco networking labs              | CCNA / CCNP       |
| EVE-NG                   | Advanced     | Enterprise multi-vendor labs            | CCNP / CCIE       |
| Mininet                  | Advanced     | SDN and OpenFlow environments           | Advanced          |
| NS-3                     | Advanced     | Network simulation and protocol testing | Research          |
| OMNeT++                  | Advanced     | Academic and protocol simulation        | Research          |
| NetSim                   | Intermediate | Training and protocol learning          | CCNA / CCNP       |
| OPNET (Riverbed Modeler) | Expert       | Enterprise network modeling             | Enterprise        |
| QualNet                  | Expert       | Wireless and military-grade simulations | Research          |

---

## Recommended Learning Path

### CCNA Foundation

Focus Areas:

* OSI Model
* TCP/IP
* IPv4 & IPv6
* Subnetting
* VLANs
* Trunking
* STP
* Routing Fundamentals
* DHCP
* DNS
* NAT

Tools:

* Cisco Packet Tracer
* Wireshark
* Windows Networking Tools

---

### CCNP Enterprise

Focus Areas:

* OSPF
* BGP
* Advanced Switching
* VPN Technologies
* Enterprise Troubleshooting
* Network Monitoring
* FortiGate Administration
* Citrix Infrastructure
* VoIP Systems
* Automation

Tools:

* GNS3
* EVE-NG
* FortiGate VM
* Hyper-V
* VMware

---

### CCIE Enterprise

Focus Areas:

* Enterprise Architecture
* MPLS
* SD-WAN
* Large Scale Routing
* Multi-Vendor Integration
* High Availability
* Network Design
* Advanced Troubleshooting

Tools:

* EVE-NG
* Multi-Vendor Virtual Labs
* Enterprise Monitoring Platforms

---

### Security & Penetration Testing

Focus Areas:

* Network Hardening
* Vulnerability Assessment
* Threat Modeling
* MITRE ATT&CK
* OWASP Methodologies
* Security Monitoring
* Penetration Testing
* Traffic Analysis

Tools:

* Wireshark
* Kali Linux
* Pentest Tools
* OWASP Resources
* NIST Frameworks

---

## Lab Areas

### Network Monitoring

Tools and procedures for:

* Latency Monitoring
* Packet Loss Detection
* Route Analysis
* Availability Monitoring
* Service Monitoring
* Infrastructure Health Checks
* Performance Baselines

---

### Routing & Switching

Topics related to:

* Layer 2 Switching
* VLANs
* Trunking
* STP
* OSPF
* BGP
* Routing Design
* Redundancy
* High Availability

---

### Firewalls & Security

Infrastructure and security-focused documentation:

* FortiGate
* FortiSwitch
* NAT
* Security Policies
* Traffic Inspection
* SSL Inspection
* Access Control
* VPN Technologies

---

### VPN & Remote Access

Technologies and troubleshooting:

* SSL VPN
* IPsec VPN
* Split Tunneling
* Full Tunneling
* MTU Issues
* Session Stability
* Remote Connectivity

---

### Citrix

Operational and troubleshooting documentation:

* ICA Connectivity
* Session Reliability
* CGP
* StoreFront
* Citrix Gateway
* Performance Analysis
* Connectivity Diagnostics

---

### VoIP

Voice infrastructure diagnostics:

* SIP
* RTP
* PBX Connectivity
* Registration Issues
* Audio Quality Analysis
* Call Stability
* Network Quality Monitoring

---

### Security & Assessment

Topics related to:

* Vulnerability Assessment
* Security Auditing
* Threat Analysis
* MITRE ATT&CK
* OWASP Testing
* Security Monitoring
* Penetration Testing Labs

---

### Automation

Operational automation and scripting:

* PowerShell
* Windows Networking
* Monitoring Scripts
* Log Collection
* Automated Diagnostics
* Infrastructure Automation

---

## Technologies & Platforms

### Network Infrastructure

* Cisco
* Fortinet
* MikroTik
* Layer 2 Networks
* Layer 3 Networks

### Virtualization

* Hyper-V
* VMware
* Virtual Appliances

### Monitoring & Analysis

* Wireshark
* PathPing
* Tracert
* Netstat
* PowerShell Diagnostics

### Security

* OWASP
* MITRE ATT&CK
* NIST
* Pentest Tools

### Remote Access

* SSL VPN
* IPsec VPN
* Pulse Secure

### Application Delivery

* Citrix Workspace
* ICA
* Session Reliability (CGP)

### Voice

* SIP
* RTP
* MicroSIP

### Operating Systems

* Windows 10
* Windows 11
* Windows Server

### Automation

* PowerShell
* CMD
* Batch Scripts

---

## Philosophy

All content in this repository is based on practical investigation and operational experience.

The focus is on:

* Reproducible Troubleshooting
* Root Cause Analysis
* Monitoring Methodologies
* Infrastructure Visibility
* Operational Reliability
* Documentation Quality
* Security Awareness

Every guide, script, and procedure should help answer a single question:

> Where is the failure occurring, and how can it be proven?

---

## Disclaimer

This repository is intended for educational, laboratory, research, testing, and operational documentation purposes.

Always validate configurations, scripts, and procedures in a controlled environment before applying changes to production systems.

The repository owner is not responsible for any damage, service interruption, security impact, or data loss resulting from the use of the provided materials.
