cls

# funkce, seriove cislo jednotky
function SN ( [string] $driveLetter ) {
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$driveLetter'" | ForEach-Object { $_.GetRelated("Win32_DiskPartition") } | ForEach-Object { $_.GetRelated("Win32_DiskDrive") }
$HardwareSN = $disk.SerialNumber
echo "sn $driveLetter $HardwareSN"
}

$pole_out = @()

for ( $aa = 65; $aa -le 90; $aa++ ) { # A-Z viz. Ascii tabulka
           
$x = ""                    
$x += [char] $aa
$x += ":"
#echo $x
$pole_out += SN $x
}

echo $pole_out

$file = "sn.txt"
Remove-Item $file -ErrorAction SilentlyContinue
sleep 1
Set-Content -Path $file -Encoding ASCII -Value $pole_out
echo "zapsano do souboru $file"
sleep 10

