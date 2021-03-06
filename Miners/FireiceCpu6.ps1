﻿using module ..\Include.psm1

$Threads = 6

$Path = ".\Bin\CryptoNight-CPU\xmr-stak-cpu.exe"
$Uri = "https://github.com/fireice-uk/xmr-stak-cpu/releases/download/v1.3.0-1.5.0/xmr-stak-cpu-win64.zip"

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName
$Port = 3334 + (0 * 10000)

([PSCustomObject]@{
        cpu_threads_conf = @([PSCustomObject]@{low_power_mode = $false; no_prefetch = $true; affine_to_cpu = $false}) * $Threads
        use_slow_memory  = "warn"
        nicehash_nonce   = $true
        aes_override     = $null
        use_tls          = $Pools.CryptoNight.SSL
        tls_secure_algo  = $true
        tls_fingerprint  = ""
        pool_address     = "$($Pools.CryptoNight.Host):$($Pools.CryptoNight.Port)"
        wallet_address   = "$($Pools.CryptoNight.User)"
        pool_password    = "$($Pools.CryptoNight.Pass)"
        call_timeout     = 10
        retry_time       = 10
        giveup_limit     = 0
        verbose_level    = 3
        h_print_time     = 60
        daemon_mode      = $false
        output_file      = ""
        httpd_port       = $Port
        prefer_ipv4      = $true
    } | ConvertTo-Json -Depth 10) -replace "^{" -replace "}$" | Set-Content "$(Split-Path $Path)\$($Pools.CryptoNight.Name)_CryptoNight_$($Threads).txt" -Force -ErrorAction SilentlyContinue

[PSCustomObject]@{
    Type      = "CPU"
    Path      = $Path
    Arguments = "-c $($Pools.CryptoNight.Name)_CryptoNight_$($Threads).txt"
    HashRates = [PSCustomObject]@{CryptoNight = $Stats."$($Name)_CryptoNight_HashRate".Week}
    API       = "FireIce"
    Port      = $Port
    Wrap      = $false
    URI       = $Uri
}