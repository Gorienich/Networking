# Call Center Network Diagnostic Tool

A PowerShell-based network diagnostic and monitoring tool designed to identify intermittent connectivity issues across CRM, Citrix, VPN, VoIP, firewall, and ISP infrastructure.

The tool continuously monitors network health and automatically collects diagnostic evidence when packet loss, latency spikes, route failures, service interruptions, or MTU issues are detected.

---

## Features

### Connectivity Monitoring

Continuously verifies connectivity between the endpoint and critical infrastructure:

* FortiGate Firewall
* Provider Router / ISP Gateway
* Mobile Backup Router
* CRM / Citrix Server
* VoIP / SIP Server

### Service Availability Checks

Validates TCP connectivity for:

* Citrix ICA (1494)
* Citrix Session Reliability / CGP (2598)
* Citrix Gateway / SSL (443)
* SIP Services (5060 / 5061)

### Latency Monitoring

Measures round-trip latency and detects:

* Network congestion
* Routing instability
* ISP performance degradation
* VPN performance issues

### Packet Loss Detection

Automatically identifies:

* Connection drops
* Packet loss
* Service interruptions
* Network instability

### Route Analysis

Collects:

* Traceroute results
* Route table information
* Active routing paths
* Hop-by-hop diagnostics

### DNS Diagnostics

Captures:

* DNS client configuration
* DNS server assignments
* Hostname resolution results

### MTU & Fragmentation Analysis

Tests packet sizes to identify:

* MTU mismatches
* Fragmentation issues
* VPN overhead limitations
* Citrix/Pulse Secure tunnel constraints

---

# Typical Issues Investigated

This tool is useful for troubleshooting:

* CRM freezes for 30–60 seconds and then recovers
* Citrix session instability
* Pulse Secure disconnects
* VPN tunnel interruptions
* SIP registration failures
* VoIP call quality issues
* One-way audio problems
* Random latency spikes
* ISP routing problems
* MTU and fragmentation issues

---

# Prerequisites

* Windows 10 / Windows 11
* PowerShell 5.1+
* Local Administrator privileges
* Network access to monitored systems

Run PowerShell as Administrator.

---

# Initial Discovery

Before configuring the script, identify the required infrastructure IP addresses.

## Local Network Information

```cmd
ipconfig /all
```

Record:

* IPv4 Address
* Default Gateway
* DNS Servers

---

## Routing Information

```cmd
route print
```

Identify:

```text
0.0.0.0 -> Default Gateway
```

---

## Citrix / CRM Server Discovery

Open CRM and run:

```cmd
netstat -ano | findstr ESTABLISHED
```

Look for Citrix-related ports:

```text
1494
2598
443
```

Example:

```text
8.200.80.113:1494
```

---

## VoIP / SIP Server Discovery

While the softphone is active:

```cmd
netstat -ano | findstr :5060
netstat -ano | findstr :5061
```

Record the SIP server address.

---

# Configuration

Update the configuration section inside the script:

```powershell
CRMHost        = "8.200.80.113"
CRMPort        = 1494
CRMPortCGP     = 2598

VoipHost       = "192.168.1.50"
VoipPort       = 5060

FortiGate      = "192.168.1.1"
ProviderRouter = "192.168.1.254"
MobileRouter   = "192.168.2.1"
```

---

# Running the Tool

Allow script execution for the current PowerShell session:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
```

Run:

```powershell
.\CallCenter-NetworkDiagnostic.ps1
```

---

# What Happens During Monitoring

Every monitoring cycle the tool:

1. Tests ICMP connectivity
2. Measures latency
3. Verifies service ports
4. Records results to CSV
5. Detects failures and threshold breaches

When a problem is detected, the tool automatically collects:

* IP configuration
* DNS configuration
* Routing table
* Active TCP connections
* Citrix-related connections
* Traceroute results
* PathPing packet-loss analysis
* MTU tests
* Route tracing information

---

# Output Files

## Diagnostic Log

```text
network_diag_<computer>_<timestamp>.log
```

Contains:

* Diagnostic dumps
* Route analysis
* DNS information
* MTU results
* Connection snapshots
* Packet-loss analysis

---

## Monitoring CSV

```text
network_samples_<computer>_<timestamp>.csv
```

Contains:

* Timestamp
* Connectivity status
* Latency measurements
* Service availability
* Monitoring results

Compatible with:

* Microsoft Excel
* Power BI
* Looker Studio
* CSV Analytics Tools

---

# Interpreting Results

## FortiGate Failure

```text
FortiGate = FAIL
CRM = FAIL
VOIP = FAIL
```

Possible causes:

* Local network issue
* Switch failure
* FortiGate problem

---

## Provider Failure

```text
FortiGate = OK
CRM = FAIL
VOIP = FAIL
```

Possible causes:

* ISP outage
* Routing issue
* Provider instability

---

## CRM Failure Only

```text
FortiGate = OK
VOIP = OK
CRM = FAIL
```

Possible causes:

* Citrix infrastructure issue
* CRM provider issue
* VPN tunnel instability

---

## VoIP Failure Only

```text
CRM = OK
VOIP = FAIL
```

Possible causes:

* SIP provider issue
* NAT problem
* PBX issue
* VoIP routing issue

---

## MTU / Fragmentation Issues

Example:

```text
1472 FAIL
1360 OK
```

Possible causes:

* VPN overhead
* MTU mismatch
* Packet fragmentation
* Tunnel encapsulation limits

---

# Recommended Deployment

For large environments, deploy the tool on:

* Agent workstations
* Supervisor workstations
* IT administration workstations
* Different switch segments or VLANs

Comparing timestamps across multiple endpoints helps determine whether an outage affects:

```text
Single Endpoint
Switch Segment
VLAN
Entire Site
ISP Connectivity
VPN Infrastructure
CRM Datacenter
VoIP Provider
```

---

# Disclaimer

This tool is intended for troubleshooting, diagnostics, and operational monitoring.

Always validate findings before making production infrastructure changes.
