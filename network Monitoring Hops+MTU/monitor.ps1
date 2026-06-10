# ============================================================
# CALL CENTER NETWORK FULL DIAGNOSTIC
#
# Purpose:
# Detect intermittent CRM / Citrix / VOIP network issues and
# collect evidence about where the failure occurs.
#
# Checks:
# 1. Endpoint -> Fortigate
# 2. Endpoint -> Provider router
# 3. Endpoint -> Mobile router
# 4. Endpoint -> CRM / Citrix server
# 5. Endpoint -> VOIP / SIP server
# 6. TCP service ports
# 7. Hops / route path
# 8. MTU / fragmentation
# 9. DNS and route diagnostics
#
# Run PowerShell as Administrator.
# ============================================================

# ----------------------------
# MAIN CONFIGURATION
# ----------------------------
$Config = @{
    # Folder where logs and CSV samples will be saved
    LogDir = "C:\Temp\crm_log"

    # CRM / Citrix server IP address or hostname
    CRMHost = "CHANGE_ME_CRM_SERVER_IP_OR_HOSTNAME"

    # Citrix ICA port.
    # Common values:
    # 1494 = Citrix ICA
    # 443  = Citrix Gateway / SSL
    CRMPort = 1494

    # Citrix Session Reliability / CGP port.
    # Common values:
    # 2598 = Citrix CGP
    # 443  = Citrix Gateway / SSL
    CRMPortCGP = 2598

    # VOIP / SIP server, PBX, or VOIP router IP address
    VoipHost = "CHANGE_ME_VOIP_SERVER_OR_ROUTER_IP"

    # SIP port.
    # Common values:
    # 5060 = SIP
    # 5061 = SIP TLS
    VoipPort = 5060

    # Local Fortigate firewall IP address
    FortiGate = "CHANGE_ME_FORTIGATE_IP"

    # Main ISP / provider router IP address
    ProviderRouter = "CHANGE_ME_PROVIDER_ROUTER_IP"

    # Mobile 4G / 5G backup router IP address
    MobileRouter = "CHANGE_ME_MOBILE_ROUTER_IP"

    # Monitoring interval in seconds
    IntervalSec = 1

    # Number of failed checks before running full diagnostics
    DropThreshold = 2

    # Latency above this value is treated as a problem
    HighLatencyMs = 300
}

# ----------------------------
# STARTUP VALIDATION
# ----------------------------
$RequiredFields = @(
    "CRMHost",
    "VoipHost",
    "FortiGate",
    "ProviderRouter",
    "MobileRouter"
)

foreach ($field in $RequiredFields) {
    if ($Config[$field] -like "CHANGE_ME*") {
        throw "Configuration error: please update '$field' before running this script."
    }
}

# ----------------------------
# CREATE LOG FILES
# ----------------------------
$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$LogFile = Join-Path $Config.LogDir "network_diag_$env:COMPUTERNAME`_$TimeStamp.log"
$CsvFile = Join-Path $Config.LogDir "network_samples_$env:COMPUTERNAME`_$TimeStamp.csv"

# Create log folder if it does not exist
New-Item -ItemType Directory -Path $Config.LogDir -Force | Out-Null

# ----------------------------
# WRITE TEXT LOG
# ----------------------------
function Write-Log {
    param(
        [string]$Text
    )

    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Text"
    $line | Tee-Object -FilePath $LogFile -Append
}

# ----------------------------
# SIMPLE PING TEST
# ----------------------------
function Test-Ping {
    param(
        [string]$Target
    )

    $result = ping.exe -n 1 -w 1000 $Target
    $success = $LASTEXITCODE -eq 0

    $latency = $null

    if ($result -match "time[=<]([0-9]+)ms") {
        $latency = [int]$matches[1]
    }

    return [PSCustomObject]@{
        Target    = $Target
        Success   = $success
        LatencyMs = $latency
        Raw       = ($result -join " ")
    }
}

# ----------------------------
# TCP PORT TEST
# ----------------------------
function Test-TcpPort {
    param(
        [string]$Target,
        [int]$Port
    )

    try {
        $tcp = Test-NetConnection `
            -ComputerName $Target `
            -Port $Port `
            -WarningAction SilentlyContinue

        return $tcp.TcpTestSucceeded
    }
    catch {
        return $false
    }
}

# ----------------------------
# MTU / FRAGMENTATION TEST
#
# Important:
# ICMP payload + 28 bytes = total IP packet size.
# 1472 payload + 28 bytes = 1500 MTU.
#
# For Citrix / Pulse / VPN / Fortigate inspection,
# real usable MTU may be lower, often around 1300-1380.
# ----------------------------
function Test-MTU {
    param(
        [string]$Target
    )

    $sizes = @(
        1472,
        1464,
        1452,
        1440,
        1420,
        1400,
        1380,
        1360,
        1340,
        1320,
        1300,
        1280,
        1260,
        1240,
        1200
    )

    foreach ($size in $sizes) {
        ping.exe $Target -n 2 -f -l $size -w 1000 | Out-Null

        $ok = $LASTEXITCODE -eq 0
        $packetTotal = $size + 28

        if ($ok) {
            Write-Log "MTU OK: Payload=$size TotalPacket=$packetTotal Target=$Target"
        }
        else {
            Write-Log "MTU FAIL/FRAGMENT: Payload=$size TotalPacket=$packetTotal Target=$Target"
        }
    }
}

# ----------------------------
# HOPS / ROUTE TEST
# ----------------------------
function Test-Hops {
    param(
        [string]$Target,
        [string]$Name
    )

    Write-Log "--- TRACERT HOPS TO $Name / $Target ---"

    tracert -d -h 20 $Target | Out-File $LogFile -Append
}

# ----------------------------
# DNS DIAGNOSTICS
# ----------------------------
function Test-DnsDiagnostics {
    param(
        [string]$Target
    )

    Write-Log "--- DNS CLIENT CONFIGURATION ---"
    Get-DnsClientServerAddress | Out-File $LogFile -Append

    Write-Log "--- DNS LOOKUP FOR $Target ---"
    nslookup $Target | Out-File $LogFile -Append
}

# ----------------------------
# FULL DIAGNOSTIC DUMP
# Runs only when packet loss, latency, or port failure is detected.
# ----------------------------
function Dump-Diagnostics {
    param(
        [string]$Reason
    )

    Write-Log "==================== FULL DIAGNOSTIC START: $Reason ===================="

    Write-Log "--- IP CONFIG ---"
    ipconfig /all | Out-File $LogFile -Append

    Write-Log "--- DNS DIAGNOSTICS ---"
    Test-DnsDiagnostics -Target $Config.CRMHost

    Write-Log "--- ROUTE PRINT ---"
    route print | Out-File $LogFile -Append

    Write-Log "--- ROUTE TO CRM USING TEST-NETCONNECTION ---"
    Test-NetConnection $Config.CRMHost -TraceRoute |
        Out-File $LogFile -Append

    Write-Log "--- ACTIVE TCP CONNECTIONS ---"
    netstat -ano | Out-File $LogFile -Append

    Write-Log "--- CRM / CITRIX CONNECTIONS ---"
    netstat -ano | findstr $Config.CRMHost | Out-File $LogFile -Append

    Test-Hops -Target $Config.FortiGate -Name "FORTIGATE"
    Test-Hops -Target $Config.ProviderRouter -Name "PROVIDER ROUTER"
    Test-Hops -Target $Config.MobileRouter -Name "MOBILE ROUTER"
    Test-Hops -Target $Config.CRMHost -Name "CRM / CITRIX"
    Test-Hops -Target $Config.VoipHost -Name "VOIP"

    Write-Log "--- PATHPING CRM / PACKET LOSS BY HOP ---"
    pathping -n -q 20 -p 250 $Config.CRMHost |
        Out-File $LogFile -Append

    Write-Log "--- PATHPING VOIP / PACKET LOSS BY HOP ---"
    pathping -n -q 20 -p 250 $Config.VoipHost |
        Out-File $LogFile -Append

    Write-Log "--- MTU / FRAGMENTATION TEST TO CRM ---"
    Test-MTU -Target $Config.CRMHost

    Write-Log "--- MTU / FRAGMENTATION TEST TO VOIP ---"
    Test-MTU -Target $Config.VoipHost

    Write-Log "==================== FULL DIAGNOSTIC END ===================="
}

# ----------------------------
# START LOGGING
# ----------------------------
Write-Log "START NETWORK MONITORING"
Write-Log "Endpoint=$env:COMPUTERNAME User=$env:USERNAME"
Write-Log "CRM=$($Config.CRMHost):$($Config.CRMPort)/$($Config.CRMPortCGP)"
Write-Log "VOIP=$($Config.VoipHost):$($Config.VoipPort)"
Write-Log "Fortigate=$($Config.FortiGate)"
Write-Log "ProviderRouter=$($Config.ProviderRouter)"
Write-Log "MobileRouter=$($Config.MobileRouter)"

# CSV header for Excel / BI review
"Time,Computer,FortigatePing,FortigateMs,ProviderPing,ProviderMs,MobilePing,MobileMs,CRMPing,CRMLatencyMs,CRMPortMain,CRMPortCGP,VoipPing,VoipLatencyMs,VoipPort" |
    Out-File $CsvFile -Encoding UTF8

$failCount = 0

# ----------------------------
# MAIN MONITORING LOOP
# Runs until PowerShell window is closed.
# ----------------------------
while ($true) {
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Ping important network points
    $forti = Test-Ping $Config.FortiGate
    $provider = Test-Ping $Config.ProviderRouter
    $mobile = Test-Ping $Config.MobileRouter
    $crm = Test-Ping $Config.CRMHost
    $voip = Test-Ping $Config.VoipHost

    # Test Citrix / CRM ports
    $crmTcpMain = Test-TcpPort $Config.CRMHost $Config.CRMPort
    $crmTcpCGP = Test-TcpPort $Config.CRMHost $Config.CRMPortCGP

    # Test VOIP / SIP port
    $voipTcp = Test-TcpPort $Config.VoipHost $Config.VoipPort

    # Save sample to CSV
    "$now,$env:COMPUTERNAME,$($forti.Success),$($forti.LatencyMs),$($provider.Success),$($provider.LatencyMs),$($mobile.Success),$($mobile.LatencyMs),$($crm.Success),$($crm.LatencyMs),$crmTcpMain,$crmTcpCGP,$($voip.Success),$($voip.LatencyMs),$voipTcp" |
        Out-File $CsvFile -Append -Encoding UTF8

    # Decide whether this sample is problematic
    $bad =
        !$forti.Success -or
        !$crm.Success -or
        !$voip.Success -or
        !$crmTcpMain -or
        !$crmTcpCGP -or
        ($crm.LatencyMs -ne $null -and $crm.LatencyMs -gt $Config.HighLatencyMs) -or
        ($voip.LatencyMs -ne $null -and $voip.LatencyMs -gt $Config.HighLatencyMs)

    if ($bad) {
        $failCount++

        Write-Log "WARNING failCount=$failCount Forti=$($forti.Success)/$($forti.LatencyMs)ms Provider=$($provider.Success)/$($provider.LatencyMs)ms Mobile=$($mobile.Success)/$($mobile.LatencyMs)ms CRM=$($crm.Success)/$($crm.LatencyMs)ms CRMMain=$crmTcpMain CRMCGP=$crmTcpCGP VOIP=$($voip.Success)/$($voip.LatencyMs)ms VOIPPort=$voipTcp"

        if ($failCount -ge $Config.DropThreshold) {
            Dump-Diagnostics -Reason "DROP / HIGH LATENCY / PORT FAILURE DETECTED"
            $failCount = 0
        }
    }
    else {
        $failCount = 0
    }

    Start-Sleep -Seconds $Config.IntervalSec
}
