cls

$pole_usb_sn = @(

# 16 Gb flesky
"0B7124105040",  # 16 Gb bila vysouvaci fleska Adata - knihovna [0]
"AA00000000000489", # 16 Gb cerna Adata [1]

# 32 Gb flesky, obsahuje exclude radek "C:\Users\DELL\Documents\zaloha\vypalit_na_BD"
"4C530001261101120300", # 32 Gb flaska Dokumenty cerna ( bez dratku ) [2]
"121220160204", # 32 Gb SD karta v redukci (dokumenty) [3] POZOR TOTO JE SN USB REDUKCE NIKOLIV KARTY V REDUKCI !!

# 64 Gb 
"01915518", # 64 Gb SD karta, uvnitr noteboooku [4]

# ostatni vice nez 64 Gb
"4C530001131108110192", # fleska 256 GB sync all [5]
"0101523124291ec35e73", # fleska 256 Gb televize setup box [6] POZOR ZDE TROCHU JINAK !
"801130168383",  # box 3 - ssd disk v cernym boxu [7] sync all
"3000CCCCBBBBAAAA", # 1,5 Tb velkej box [8] sync all

"0000e5cf7a5a", # GPS-ka Garmnin [9]
"E20312161846", #  320 Gb bilej box Hdd, zatim vynechano, slozi pro historii souboru sluzba windows 10
"9C053654B907", # pridano 31.4.2026, sdd disk v bilim supliku, puvodne z Xboxu 360 (pouzit ho stejne jako cernej suplik) [11]
#"WXF2E21E6V2F" # nefungoovalo 
"WXF2E21E6V2F    " # takto funguje pridano 3.6.2026 extterni Hdd Western Digital - 4 Tb [12]
)

$d_pole_usb_sn = $pole_usb_sn.Length
echo "celkem registrovanych jednotek - $d_pole_usb_sn" # pocet registrovanych SN jednotek 

# pismena jednotek ktera bude ignorovat
$ignore = @("C:", "D:") # D: dvd-vypalovacka v notebooku a C: systemovej disk

# najde vsechny logicke disky krome C: a D:
$logical = Get-WmiObject Win32_LogicalDisk | Where-Object { $ignore -notcontains $_.DeviceID }

# prozdny pole pro vysledky
$results = @()

foreach ($ld in $logical) {

# najde partition
$partition = $ld.GetRelated("Win32_DiskPartition")
foreach ($p in $partition) {

# najde fyzicky disk
$disk = $p.GetRelated("Win32_DiskDrive")
foreach ($d in $disk) {

# ulozime do objektu
$results += [PSCustomObject]@{
DriveLetter = $ld.DeviceID
Model = $d.Model
HardwareSN = $d.SerialNumber
DeviceID = $d.DeviceID
}}}}

#$results
$d_results = $results.Length
echo "celkovy nalezenych pocet pripojenych USB jednotek - $d_results"
echo ""

for ( $aa = 0; $aa -le $d_results -1; $aa++ ) {
$jednotka_pismeno = $results[$aa].DriveLetter
$jednotka_model = $results[$aa].Model
$jednotka_sn = $results[$aa].HardwareSN
#echo "$jednotka_pismeno $jednotka_model - $jednotka_sn"


# pro 16 GB ( zluta )
if ((
( $jednotka_sn -like $pole_usb_sn[0] ) -or 
( $jednotka_sn -like $pole_usb_sn[1] ) -or 
( $jednotka_sn -like $pole_usb_sn[2] )
)) {
Write-Host -ForegroundColor Yellow "$jednotka_pismeno $jednotka_model - $jednotka_sn"
Write-Host -ForegroundColor Yellow "$jednotka_pismeno 16 Gb"
}


# pro 32 Gb ( cyan )
if (
( $jednotka_sn -like $pole_usb_sn[3] ) -or 
( $jednotka_sn -like $pole_usb_sn[4] )
) {
Write-Host -ForegroundColor cyan "$jednotka_pismeno $jednotka_model - $jednotka_sn"
Write-Host -ForegroundColor cyan "$jednotka_pismeno 32 Gb"
}


# pro 64 Gb ( modra )
if ( $jednotka_sn -like $pole_usb_sn[5] ) {
Write-Host -ForegroundColor blue "$jednotka_pismeno $jednotka_model - $jednotka_sn"
Write-Host -ForegroundColor blue "$jednotka_pismeno 64 Gb SD karta uvnitr v notebooku"
}

# ostatni vice nez 64 Gb ( red ) 
if ((
( $jednotka_sn -like $pole_usb_sn[6] ) -or
( $jednotka_sn -like $pole_usb_sn[8] ) -or
( $jednotka_sn -like $pole_usb_sn[9] ) # novinka rozdeleni vyce podminek na vice radku :) ( prehlednejsi reseni )
)) {
Write-Host -ForegroundColor red "$jednotka_pismeno $jednotka_model - $jednotka_sn"
Write-Host -ForegroundColor red "$jednotka_pismeno vice nezli 64 Gb"
}

# pouze pro fleska televize ( dela se trochu jinak ! )
if ( $jednotka_sn -like $pole_usb_sn[7] ) {
Write-Host -ForegroundColor magenta
"$jednotka_pismeno $jednotka_model - $jednotka_sn"
Write-Host -ForegroundColor magenta "fleska televize"

}
echo ""
}


Read-Host -Prompt "Press ENTER to continue . . ."
sleep 1



