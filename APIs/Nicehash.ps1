﻿using module ..\Include.psm1

class Nicehash : Miner {
    [PSCustomObject]GetHashRate ([String[]]$Algorithm, [Bool]$Safe = $false) {
        $Server = "localhost"
        $Timeout = 10 #seconds

        $Delta = 0.05
        $Interval = 5
        $HashRates = @()

        $Request = @{id = 1; method = "algorithm.list"; params = @()} | ConvertTo-Json -Compress

        do {
            $HashRates += $HashRate = [PSCustomObject]@{}

            try {
                $Response = Invoke-TcpRequest $Server $this.Port $Request $Timeout -ErrorAction Stop
                $Data = $Response | ConvertFrom-Json -ErrorAction Stop
            }
            catch {
                Write-Warning "Failed to connect to miner ($($this.Name)). "
                break
            }

            $Data.algorithms.name | Select-Object -Unique | ForEach-Object {
                $HashRate_Name = [String]$_
                $HashRate_Value = [Double](($Data.algorithms | Where-Object name -EQ $_).workers.speed | Measure-Object -Sum).Sum

                if ($HashRate_Name -and ($Algorithm -like (Get-Algorithm $HashRate_Name)).Count -eq 1) {
                    $HashRate | Add-Member @{(Get-Algorithm $HashRate_Name) = [Int]$HashRate_Value}
                }
            }

            $Algorithm | Where-Object {-not $HashRate.$_} | ForEach-Object {break}

            if (-not $Safe) {break}

            Start-Sleep $Interval
        } while ($HashRates.Count -lt 6)

        $HashRate = [PSCustomObject]@{}
        $Algorithm | ForEach-Object {$HashRate | Add-Member @{$_ = [Int]($HashRates.$_ | Measure-Object -Maximum -Minimum -Average | Where-Object {$_.Maximum - $_.Minimum -le $_.Average * $Delta}).Maximum}}
        $Algorithm | Where-Object {-not $HashRate.$_} | Select-Object -First 1 | ForEach-Object {$Algorithm | ForEach-Object {$HashRate.$_ = [Int]0}}

        return $HashRate
    }
}