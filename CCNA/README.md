# 🛡️ CCNA & Windows System Administrator Troubleshooting Handbook

A practical troubleshooting and command reference handbook designed for daily use by:

* Help Desk T1
* Help Desk T2
* System Administrators
* Junior Network Administrators
* CCNA students transitioning into real-world operations

This project focuses on production troubleshooting rather than certification theory.

---

# 🎯 Goal

The purpose of this handbook is to provide a fast operational reference for diagnosing and resolving real infrastructure issues using:

* Cisco IOS
* Windows 10 / 11
* Windows Server
* Active Directory
* Enterprise LAN environments
* VLANs and Switching
* Routing
* DNS
* DHCP
* VPN
* Network Services

The handbook is organized using the OSI model to create a structured troubleshooting methodology.

---

# 🧠 Troubleshooting Philosophy

Always troubleshoot from the bottom up:

```text
Layer 1 → Physical Connectivity
Layer 2 → Local Network Communication
Layer 3 → Routing & Reachability
Layer 4 → Transport & Ports
Layer 7 → Applications & Services
```

Do not skip layers.

A DNS problem cannot be solved if Layer 3 is broken.

A routing problem cannot be solved if Layer 2 is broken.

---

# 📚 Covered Topics

## Layer 1 – Physical

* Ethernet Cabling
* Fiber Optics
* SFP / SFP+
* PoE
* Interface Troubleshooting
* Physical Layer Diagnostics

---

## Layer 2 – Data Link

* Ethernet
* MAC Address
* ARP
* VLAN
* Trunking
* Access Ports
* STP
* EtherChannel (LACP / PAgP)
* CDP
* LLDP
* Port Security

---

## Layer 3 – Network

* IPv4 Addressing
* Subnetting
* Routing Tables
* Static Routing
* OSPF
* DHCP Relay
* NAT
* ICMP
* Ping
* Traceroute

---

## Layer 4 – Transport

* TCP
* UDP
* Port Troubleshooting
* Session Analysis

---

## Layer 7 – Application

* DNS
* SSH
* Application Troubleshooting

Future additions:

* Active Directory
* Group Policy
* Kerberos
* SMB
* RDP
* Hyper-V
* Citrix
* Windows Firewall
* Certificates
* VPN Troubleshooting

---

# ⚡ Structure

Each section follows the same format:

```text
Overview

Core Commands

Flashcards
Problem → Command → Why

Troubleshooting Workflow

Best Practices
```

Example:

```text
Problem:
User receives wrong IP address

Command:
show interfaces g0/1 switchport

Why:
Wrong VLAN assignment
```

---

# 🎴 Flashcard Design

The handbook uses operational flashcards instead of theory-heavy notes.

Focus:

```text
Problem
↓
Command
↓
Why
```

This allows quick decision-making during live incidents.

---

# 🛠 Technologies

### Cisco

* Cisco IOS
* VLAN
* STP
* EtherChannel
* OSPF
* NAT
* DHCP

### Microsoft

* Windows 10
* Windows 11
* Windows Server
* PowerShell
* Networking Stack

---

# 🚀 Learning Path

Current:

```text
CCNA Certified
```

Next:

```text
CCNP ENCOR
```

Future:

```text
System Administration
Network Administration
Infrastructure Engineering
```

---

# 📖 How To Use

When troubleshooting:

1. Identify the symptom.
2. Find the matching OSI layer.
3. Open the relevant chapter.
4. Follow the Troubleshooting Workflow.
5. Use the Flashcards section for quick command lookup.
6. Review Best Practices after resolving the issue.

---

# 🤝 Contributing

This handbook is a living document.

New commands, incidents, troubleshooting workflows, and lessons learned from production environments should be added continuously.

The goal is to build a practical operational knowledge base rather than a certification notebook.

---

# ⭐ Philosophy

Understanding commands is important.

Understanding when and why to use them during a real incident is what turns knowledge into experience.
