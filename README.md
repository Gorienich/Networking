# Call Center Network Diagnostic Tool

## Purpose

This PowerShell diagnostic tool is designed to troubleshoot intermittent CRM and VOIP connectivity issues in a call center environment using:

* FortiGate Firewall
* Bezeq ISP
* Mobile 4G/5G Backup Router
* Citrix CRM Infrastructure
* Pulse Secure VPN
* VOIP / SIP Services
* Fortinet Switching Infrastructure

The tool continuously monitors connectivity and automatically collects detailed diagnostics when packet loss, latency spikes, or service interruptions are detected.

---

# Typical Symptoms This Tool Helps Investigate

* CRM freezes for 30–60 seconds and then reconnects.
* Citrix sessions become unresponsive.
* Pulse Secure disconnects and reconnects.
* MicroSIP loses registration.
* Some agents lose connectivity while others remain connected.
* Entire call center loses CRM access simultaneously.
* VOIP calls experience one-way audio or call drops.
* Random latency spikes during business hours.

---

# Before Running The Script

## Step 1 – Identify Infrastructure IP Addresses

Open CMD as Administrator.

### Find Local Gateway

```cmd
ipconfig /all
```

Record:

* IPv4 Address
* Default Gateway
* DNS Servers

Usually:

```text
Default Gateway = FortiGate
```

---

### View Routing Table

```cmd
route print
```

Record:

```text
0.0.0.0 -> Gateway
```

This shows the active internet path.

---

### Find Citrix CRM Server

Open CRM and run:

```cmd
netstat -ano | findstr ESTABLISHED
```

Check for:

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

### Find VOIP Server

While MicroSIP is running:

```cmd
netstat -ano | findstr :5060
netstat -ano | findstr :5061
```

Record the SIP server address.

---

## Step 2 – Update Script Configuration

Update:

```powershell
CRMHost
VoipHost
FortiGate
BezeqRouter
MobileRouter
```

Example:

```powershell
CRMHost     = "8.200.80.113"
VoipHost    = "192.168.1.50"
FortiGate   = "192.168.1.1"
BezeqRouter = "192.168.1.254"
MobileRouter = "192.168.2.1"
```

---

# Running The Tool

Open PowerShell as Administrator.

Allow script execution:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
```

Run:

```powershell
.\CallCenter-NetworkDiagnostic.ps1
```

---

# What The Tool Checks

## Connectivity

Every second the tool verifies:

```text
Endpoint -> FortiGate
Endpoint -> Provider Router
Endpoint -> Mobile Router
Endpoint -> CRM Server
Endpoint -> VOIP Server
```

---

## TCP Service Availability

Checks:

```text
Citrix ICA         1494
Citrix CGP         2598
VOIP SIP           5060
```

---

## Latency Monitoring

Measures round-trip latency.

Default threshold:

```text
300ms
```

Values above threshold trigger diagnostics.

---

## Packet Loss Monitoring

Detects:

```text
Lost packets
Connection failures
Timeouts
```

---

## Route Analysis

Automatically executes:

```cmd
tracert
```

to identify the hop where traffic fails.

---

## Packet Loss By Hop

Automatically executes:

```cmd
pathping
```

to identify:

```text
Switch
FortiGate
ISP
Datacenter
CRM Provider
```

packet loss locations.

---

## MTU / Fragmentation Testing

Checks packet sizes from:

```text
1200 bytes
up to
1500 bytes
```

Useful for:

```text
Pulse Secure
Citrix
VPN tunnels
SSL encapsulation
FortiGate inspection
```

---

# Generated Files

## Diagnostic Log

```text
network_diag_<computer>.log
```

Contains:

* Route information
* Traceroute results
* PathPing results
* MTU tests
* TCP connection snapshots

---

## Monitoring CSV

```text
network_samples_<computer>.csv
```

Contains:

* Timestamp
* Latency
* Packet loss
* Service status
* TCP availability

Can be imported into:

* Excel
* Power BI
* Looker Studio

---

# Interpreting Results

## FortiGate Fails

```text
FortiGate = FAIL
CRM = FAIL
VOIP = FAIL
```

Likely:

* Switch issue
* Local network issue
* FortiGate issue

---

## ISP Fails

```text
FortiGate = OK
CRM = FAIL
VOIP = FAIL
```

Likely:

* Bezeq outage
* Routing issue
* Provider issue

---

## CRM Only Fails

```text
FortiGate = OK
VOIP = OK
CRM = FAIL
```

Likely:

* Citrix infrastructure issue
* CRM provider issue
* Pulse Secure tunnel issue

---

## VOIP Only Fails

```text
CRM = OK
VOIP = FAIL
```

Likely:

* SIP provider issue
* NAT issue
* VOIP router issue

---

## MTU Failures

If:

```text
1472 FAIL
1360 OK
```

Likely:

* VPN overhead
* MTU mismatch
* Fragmentation problem

---

# Recommended Deployment

Run the tool on:

* Agent workstation
* Supervisor workstation
* IT workstation
* One workstation per switch stack

Compare timestamps between logs to determine whether the outage affects:

```text
Single PC
Single switch
Entire VLAN
Entire call center
External provider
CRM datacenter
```
