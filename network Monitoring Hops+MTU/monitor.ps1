# ============================================================
# CALL CENTER NETWORK FULL DIAGNOSTIC
# Checks:
# 1. Endpoint -> Fortigate
# 2. Endpoint -> provider router
# 3. Endpoint -> Mobile router
# 4. Endpoint -> CRM Citrix server
# 5. Endpoint -> VOIP server/router
# 6. TCP ports
# 7. Hops / route path
# 8. MTU / fragmentation
#
# Run PowerShell as Administrator
# ============================================================

# ----------------------------
# MAIN CONFIGURATION
# ----------------------------
$Config = @{
    # Folder where logs will be saved
    LogDir = "C:\Temp\crm_log"

    # CRM Citrix server from your ICA file
    CRMHost = "YOUR_CRM_SERVER_IP_OR_HOSTNAME"

    # Citrix ICA port from ICA file
    CRMPort = "YOUR_CRM_PORT_1494_OR_443"

    # Citrix Session Reliability / CGP port
    CRMPortCGP = "YOUR_CRM_PORT_2598_OR_443"

    # VOIP / SIP server or VOIP router
    VoipHost = "YOUR_VOIP_SERVER_OR_ROUTER_IP_OR_HOSTNAME"

    # SIP port
    VoipPort = "YOUR_VOIP_SIP_PORT_5060_OR_5061"

    # Local Fortigate firewall IP
    FortiGate = "YORU_FORTIGATE_IP"

    # Bezeq router gateway IP - change if different
    BezeqRouter = "YOUR_ISP_ROUTER_IP"

    # Mobile 4G/5G router IP - change if different
    MobileRouter = "YOUR_MOBILE_ROUTER_IP"

    # How often to check, in seconds
    IntervalSec = 1

    # How many bad checks before full diagnostic starts
    DropThreshold = 2

    # Latency above this value will be treated as problem
    HighLatencyMs = 300
}

# ----------------------------
# CREATE LOG FILES
# ----------------------------
$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$LogFile = Join-Path $Config.LogDir "network_diag_$env:COMPUTERNAME`_$TimeStamp.log"
$CsvFile = Join-Path $Config.LogDir "network_samples_$env:COMPUTERNAME`_$TimeStamp.csv"

# Create log folder if missing
New-Item -ItemType Directory -Path $Config.LogDir -Force | Out-Null

# ----------------------------
# WRITE NORMAL TEXT LOG
# ----------------------------
function Write-Log {
    param([string]$Text)

    # Time format for every log line
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Text"

    # Show on screen and save to log file
    $line | Tee-Object -FilePath $LogFile -Append
}

# ----------------------------
# SIMPLE PING TEST
# Checks if target answers and gets latency
# ----------------------------
function Test-Ping {
    param([string]$Target)

    # Send one ping with 1 second timeout
    $result = ping.exe -n 1 -w 1000 $Target

    # If ping command exit code is 0, ping worked
    $success = $LASTEXITCODE -eq 0

    # Default latency is empty
    $latency = $null

    # Extract latency from ping result
    if ($result -match "time[=<]([0-9]+)ms") {
        $latency = [int]$matches[1]
    }

    # Return clean object
    return [PSCustomObject]@{
        Target = $Target
        Success = $success
        LatencyMs = $latency
        Raw = ($result -join " ")
    }
}

# ----------------------------
# TCP PORT TEST
# Checks if service port is open
# Example: Citrix 1494 / 2598 / 443
# ----------------------------
function Test-TcpPort {
    param(
        [string]$Target,
        [int]$Port
    )

    try {
        $tcp = Test-NetConnection -ComputerName $Target -Port $Port -WarningAction SilentlyContinue
        return $tcp.TcpTestSucceeded
    } catch {
        return $false
    }
}

# ----------------------------
# MTU / FRAGMENTATION TEST
# Important:
# ICMP payload + 28 bytes = total IP packet
# 1472 + 28 = 1500 MTU
#
# For Citrix / Pulse / VPN / Fortigate,
# real safe value may be lower: 1300-1380
# ----------------------------
function Test-MTU {
    param([string]$Target)

    $sizes = @(1500,1492,1480,1472,1464,1452,1440,1420,1400,1380,1360,1340,1320,1300,1280,1260,1240,1200)

    foreach ($size in $sizes) {

        # -f means "do not fragment"
        # -l means packet payload size
        ping.exe $Target -n 2 -f -l $size -w 1000 | Out-Null

        $ok = $LASTEXITCODE -eq 0
        $packetTotal = $size + 28

        if ($ok) {
            Write-Log "MTU OK: Payload=$size TotalPacket=$packetTotal Target=$Target"
        } else {
            Write-Log "MTU FAIL/FRAGMENT: Payload=$size TotalPacket=$packetTotal Target=$Target"
        }
    }
}

# ----------------------------
# HOPS / ROUTE TEST
# Shows where packets go
# Good for finding if drop is:
# switch / Fortigate / router / ISP / outside provider
# ----------------------------
function Test-Hops {
    param(
        [string]$Target,
        [string]$Name
    )

    Write-Log "--- TRACERT HOPS TO $Name / $Target ---"

    # -d = do not resolve DNS, faster and cleaner
    # -h 20 = max 20 hops
    tracert -d -h 20 $Target | Out-File $LogFile -Append
}

# ----------------------------
# FULL DIAGNOSTIC
# Runs only when drop or high latency is detected
# ----------------------------
function Dump-Diagnostics {
    param([string]$Reason)

    Write-Log "==================== FULL DIAGNOSTIC START: $Reason ===================="

    # Shows IP, DNS, gateway, adapters, Pulse adapter, etc.
    Write-Log "--- IP CONFIG ---"
    ipconfig /all | Out-File $LogFile -Append

    # Shows routing table and which gateway traffic uses
    Write-Log "--- ROUTE PRINT ---"
    route print | Out-File $LogFile -Append

    # Shows all current TCP connections
    Write-Log "--- ACTIVE TCP CONNECTIONS ---"
    netstat -ano | Out-File $LogFile -Append

    # Shows only Citrix CRM connections
    Write-Log "--- CRM CITRIX CONNECTIONS ---"
    netstat -ano | findstr $Config.CRMHost | Out-File $LogFile -Append

    # Check route hops
    Test-Hops -Target $Config.FortiGate -Name "FORTIGATE"
    Test-Hops -Target $Config.BezeqRouter -Name "BEZEQ ROUTER"
    Test-Hops -Target $Config.CRMHost -Name "CRM CITRIX"
    Test-Hops -Target $Config.VoipHost -Name "VOIP"

    # Pathping gives packet loss by hop
    Write-Log "--- PATHPING CRM / PACKET LOSS BY HOP ---"
    pathping -n -q 20 -p 250 $Config.CRMHost | Out-File $LogFile -Append

    # MTU tests
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

# CSV header for Excel review
"Time,Computer,FortigatePing,FortigateMs,BezeqPing,BezeqMs,MobilePing,MobileMs,CRMPing,CRMLatencyMs,CRM1494,CRM2598,VoipPing,VoipLatencyMs,VoipPort" |
    Out-File $CsvFile -Encoding UTF8

# Counts repeated failures
$failCount = 0

# ----------------------------
# MAIN LOOP
# Runs forever until you close PowerShell
# ----------------------------
while ($true) {

    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Ping every important hop
    $forti = Test-Ping $Config.FortiGate
    $bezeq = Test-Ping $Config.BezeqRouter
    $mobile = Test-Ping $Config.MobileRouter
    $crm = Test-Ping $Config.CRMHost
    $voip = Test-Ping $Config.VoipHost

    # Test Citrix ports
    $crmTcp1494 = Test-TcpPort $Config.CRMHost $Config.CRMPort
    $crmTcp2598 = Test-TcpPort $Config.CRMHost $Config.CRMPortCGP

    # Test VOIP SIP port
    $voipTcp = Test-TcpPort $Config.VoipHost $Config.VoipPort

    # Save every sample to CSV
    "$now,$env:COMPUTERNAME,$($forti.Success),$($forti.LatencyMs),$($bezeq.Success),$($bezeq.LatencyMs),$($mobile.Success),$($mobile.LatencyMs),$($crm.Success),$($crm.LatencyMs),$crmTcp1494,$crmTcp2598,$($voip.Success),$($voip.LatencyMs),$voipTcp" |
        Out-File $CsvFile -Append -Encoding UTF8

    # Decide if current check is bad
    $bad =
        !$forti.Success -or
        !$crm.Success -or
        !$voip.Success -or
        !$crmTcp1494 -or
        !$crmTcp2598 -or
        ($crm.LatencyMs -ne $null -and $crm.LatencyMs -gt $Config.HighLatencyMs) -or
        ($voip.LatencyMs -ne $null -and $voip.LatencyMs -gt $Config.HighLatencyMs)

    # If problem detected
    if ($bad) {
        $failCount++

        Write-Log "WARNING failCount=$failCount Forti=$($forti.Success)/$($forti.LatencyMs)ms Bezeq=$($bezeq.Success)/$($bezeq.LatencyMs)ms CRM=$($crm.Success)/$($crm.LatencyMs)ms CRM1494=$crmTcp1494 CRM2598=$crmTcp2598 VOIP=$($voip.Success)/$($voip.LatencyMs)ms"

        # After repeated failures, run full diagnostic
        if ($failCount -ge $Config.DropThreshold) {
            Dump-Diagnostics -Reason "DROP / HIGH LATENCY / PORT FAIL DETECTED"
            $failCount = 0
        }
    }
    else {
        # Reset fail counter when everything is OK
        $failCount = 0
    }

    # Wait before next test
    Start-Sleep -Seconds $Config.IntervalSec
}
