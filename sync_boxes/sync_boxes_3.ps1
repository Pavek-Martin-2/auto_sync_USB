cls

echo "robocopy sync z externiho boxu 4 Tb na externi box 1,5 Tb"
Set-PSDebug -Strict

<# 
robocopy sync z externiho boxu 4 Tb na externi box 1,5 Tb ( box 4 TB neni zdaleka plny )

nehrozi ze by treba nejakou uzivatelskou chybou doslo k tomu ze by se omylem
kopiroval obracene cil --> zdroj apod. seriovy cislo jednotky je jednoznacnej udaj
takze se tim automatizaci predchazi pripadne strate dat, coz by u disku 4 Tb asi mrzelo..
jinak disk 4 TB pouzivam na zalohy ale chci to mit dvojite jeste nekde jinde, kdybych si omylem
neco vymazal, opatrnosti nejni nikdy dost, vzdycky nejslabsi je ten lidskej clanek
#>


<#
adresare v rootu ktery se budou kopirovat na cilovej disk (taky do root adresare cile)
je jich tam celkove vic, chci synchronizovat jenom nektere proto tento array vypis
jinak by to slo udelat, ze vem vsechno co je adresar napr. prikazem:
$adresare+=@(Get-ChildItem -Attributes Directory -Exclude "keys" -Name)
"+=" je duleziti, protoze kdzby byla pouze jedna polozka tak PowerShell nebude zapisovat
do promenny typu Pole ale jako String ( sou to hovada... )
takze by pak $adresare.lenght znamenalo neco jiny nez je potreba ( uz sem to popisovel nekde jinde )
takhle se mu vnuti tadovej tip v jakykoliv situaci
#>
$adresare=@(
"Audio",
"BD",
"dnes",
"JPG",
"PDF",
"SOFT",
"video"
)

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
}}}} # :)


$zdrojova_jednotka_pismeno = "asdf" # napred najaka kravina *
$cilova_jednotka_pismeno = "zxcv"

#$results
$d_results = $results.Length
for ( $aa = 0; $aa -le $d_results -1; $aa++ ) {
#$jednotka_pismeno = $results[$aa].DriveLetter
#$jednotka_model = $results[$aa].Model
#$jednotka_sn = $results[$aa].HardwareSN

$serial = $results[$aa].HardwareSN
#echo $serial
#echo $serial.Length

$pismeno_jednotky = $results[$aa].DriveLetter
#echo $pismeno_jednotky

# Hdd Western Digital - 4 Tb
if ( $serial -like "WXF2E21E6V2F    "){
# takhle vcetne tech mezer na konci, kerejch sem si samozdrejme napred vubec nesimnul
# jiny disky mezery na konci v SN nemaj, jenom tenhle
# takze stat se muze treba i toto, clovek by to vubec necekal
# pro jistotu - echo $serial.Length (spocita vsechno vcetne bylejch znaku) kdyby
# z nepochpopitelnej duvodu selhavala nejaka podminka, samozdrejme ten retezec pro porovnani
# musi bejt naprosto presny, jinak to nebude fungovat
# jinak divil jsem se ze zrovna Western Digital tak mam tohle, kdzby to byla treba nejaka
# levna cinska fleska tak nereknu ale tohle ?
$zdrojova_jednotka_pismeno = $pismeno_jednotky # aby se pak zde pripadne predefinovala *
}

# 1,5 Tb velkej box
if ( $serial -like "3000CCCCBBBBAAAA"){
$cilova_jednotka_pismeno = $pismeno_jednotky
}

}

#echo $zdrojova_jednotka_pismeno
#echo $cilova_jednotka_pismeno

if (( 
( $zdrojova_jednotka_pismeno -notlike "asdf" ) -and
( $cilova_jednotka_pismeno -notlike "zxcv" ) # a tady jestli kravina nezustala *
)){
#echo "sync"
$zdrojova_jednotka_pismeno = $zdrojova_jednotka_pismeno + "\"
$cilova_jednotka_pismeno = $cilova_jednotka_pismeno + "\"

# vypis pole adresare
for ( $bb = 0; $bb -le $adresare.Length -1; $bb++ ) {
Write-Host -ForegroundColor Yellow $zdrojova_jednotka_pismeno -nonewline
Write-Host -ForegroundColor Yellow $adresare[$bb] -nonewline
Write-Host -ForegroundColor REd " --> " -nonewline
Write-Host -ForegroundColor Yellow $cilova_jednotka_pismeno -NoNewline
Write-Host -ForegroundColor Yellow $adresare[$bb]
}

Read-Host -Prompt "press Enter to continue"

# robocopy
for ( $cc = 0; $cc -le $adresare.Length -1; $cc++ ) {
[string] $polozka_pole = $adresare[$cc]
robocopy $zdrojova_jednotka_pismeno$polozka_pole $cilova_jednotka_pismeno$polozka_pole *.* /MIR
}

Read-Host -Prompt "press Enter to continue"

}else{
Write-Warning "boxy nejsou pripojeny"
sleep 10
exit

}

