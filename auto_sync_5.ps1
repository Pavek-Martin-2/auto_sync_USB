cls
<#
program pro automatickou synchronizaci souboru a slozek v pocitaci (z disku C: ) na ruzne USB jednotky
jednotky maji ruzne velikosti napr. 16Gb, 32Gb, 64 a vice mam take v boxu stary SSD disk ktery na 128 Gb
synchronizace zjistuje utilita "robocopy.exe" ktera je beznou soucasti instalace Windows ( mam Win 10 pro )
v poly "$pole_usb_sn" jsou ulozena zjistena seriova cisla vsech USB jednonotek co mam, mam jich nekolik jak je vydet
objem zalohovani je limitovan velikosti na flesku 16GB lze kvuli omezenemu mistu zalohovat z pocitace pouze neco,
tedy to nejdulezitejsi naopak na jiz zminovany USB SSD 128 Gb disk v boxu zalohuju vsechno co se da, protoze mista je zde dost
program tedy precte seriove jednotky/jednotek a pozna jaka jednotka(y) je vlozena do pocitace a podle toho zvoli zpusob zalohovani 
mene nebo vice, podle kapacity, jednotek lze pripojit vice najednou budou postupne zpracovany vsechny postupne
program zacina zjistovat u pismene jednotky E: a pokracuje az do pismena Z:
pismeno C: a D: je zde vochopitelne preskoceno C: je pevny disk v pocitaci a D: je DVD vypalovacka
paklize se pripojuje vice USB jednotek najednou ( coz vetsinou delam ) tak zalezi na paradi pripojeni nekdy se fleska 16 GB 
prihlasi do systemu jako jednotka napr. E: a jindy ta sama zase jako napr. F: takze program musi resit i toto, coz take dela
automatizace pracuje tak ze staci k pocitaci pripojit flesky a usb disky co to jen jde 
zkontrolovat v pruzkumnikovy ve Windows jeslti se spravne pripojili a jestli vsechny maji pridelene pismeno a spustit tento program
program uz pak nepotrebuje od uzivatele vubec nic, sam detekuje vsechny pripojene jednotku podle serioveho cisla "pozna" 
jejich velikost, sam urci prislusne pismeno jednotky a provede synchronizaci metodou "malo", "vice" ," nejvice" a plus nekolik specialnich
napr. jako mam zde 256 Gb flaska televize kde je rozdil oproti jine 256 Gb flesce kterou mam take ale nechci aby se mi na televizni
synchronizovali nektere adresare jako je tomu v jinem pripade  256 Gb flesky, takze vsechno se odviji od seriovyho cisla USB jadnotky
drive kdyz jsem to nedlal rucne a nebo lepe recene pomoci nejakeho davkoveho souboru tak dochazelo k castym chybam a preklikum
nekdy jsem poplet co kam ma prijit a pak se muselo mazat a opravovat, tady dobre funguje prave takova ta neomylna boolean logika
SN je unikatni kazda SD karta nebo fleska na jiny takze omyl je zde vyloucen, takze opravdu staci pustit program a jit na
jak se rika na kafe a za pul hodiny ktomu prijit k hotovimu a omyl je vyloucen

vsimtete si naovinky: stejne tak jako promenna typo pole zde tady $pole_usb_sn tak i radky if () -or se daji "rozradkovat"
napr. radek 214-216, co me prijde fain, hodi se to a je to prehlednejsi a take se to pripadne lepe edituje, kdyz je potreba
13.3.2026


doplneni 3.4.2026
jeste jsem udelal tuhle verzi "5" ale ta uz je dost specificka a psana primo pro moje potreby, napriklad mam
redukci z SD karty na USB a daj se vni menit karty ale seriove cislo neni vlozene karty v redukci ale redukce
samotne no a mam dve SD karty jedna ma 32Gb a druha ma 4Gb takze bylo protreba rozsirit logiku/detekci ktera z techto 
svou karet je vlastne vlozena, pouzij jsem ktomu nove podmineny prikaz (IF -AND) takze krome serioveho cisla koukam i na 
velikost vlozene karty, a podle toho se pak zalohuje mane nebo vice
pozn. hotnotu "True" nabyde promenna v "Boolean" logice pouze pokud jsou splneny OBE podminky zaroven )
dale pak mam jeste starsi GPS navigaci "Garmin" a tak kdyz se pripoji pres USB kabel k pocitaci tak se v systemu
tvari jako bezny pripojeny flash disk, pochopitelne take se svim unikatnim seriovim cislem
takze toto zde pribylo ve verzi 5, ze synchronizuju vnitni pamet GPS-ky do nejakeho adresare se zalohou
pak mam 32 GB USB flesku [2] takze tam bylo potreba upravit podminku oproti verzi skriptu verze 4 drive bylo [2] -or [3]
( "dva" nebo "3", jedno z tech dvouch, ale pripadne i obe, ale pro (IF -AND) plati ze POUZE OBE ) viz. "src\Boolean.jpg"
a ted je nove [2] samostatne a [3] je nove reseny jako (IF [3] -AND 32 Gb) velikost, pro rozpoznani
takze verze pro bezne pouziti je stale starsi verze 4
skriptem "get_sn.ps1" si zjistete seriova cisla vasich usb jednotek a podle toho potom editujte prommenou pole
"$pole_usb_sn" a pochopitelne take radky "Copy-Item" a "robocopy" a jednotlivich IF podminkach
jeste je takova uzitecna vec kterou rad pouzivam v Pruzkumnikovi ve Windows je funkce "kopirovat cestu"
takze kdyz si mysi oznacite jeden ale i vice souboru a kliknete na "kopirovat cestu" tak se vam do clipboardu
prenesou absolutni cesty na tyto souboru, takze ve skriptu potom zkratka Ctrl+v vlozi radek napr.
"C:\adresar\podaresar\soubor" apod. pozor zkopiruje cestu uz i z uvozovkama, kakze ani nejni potreba, jako 
jako delam ja, ze si napisu dva znaky "" kliknu mezi ne mysi a dam Ctrl+v

vsimtete si nove pouzitiho datoviho tipu "UInt64", celocistena hodnota ktera ma vyhrazeny v pameti misto
64 bytu to uz je docela velky cislo :) a je to zde vlaste vyjadreni velikosti jednotky z bajtech takze kdyz ma disk 
kterej na 1,5 Tera bajtu tak hodnota vyjadrena v bytech je 1500299297280 takze tolik k tipu Uint64, "U" na zacatku
znamena unsigned tedy nemuze byt zaporna, je pouze kladna a minimum = 0 ; a maximum je 18446744073709551615
$min = [uint64]::MinValue; echo $min
$max = echo [uint64]::MaxValue; echo $max
# tyto dva radky si muzete vyzkouset samy ( pridano do adresar "scr\" a v "old.rar" je skript "value_4.ps1")
#>


Set-PSDebug -Strict # jakakoliv nedeklarovana promenna pri jejim zavolani udela chybu skriptu

$ExistingVariables = Get-Variable | Select-Object -ExpandProperty Name # nazev souboru skriptu do zahlavi okna
[string] $scriptName = pwd
if ( $scriptName.Length -ne 3 ) { $scriptName += "\"}
$scriptName += $MyInvocation.MyCommand.Name
$host.UI.RawUI.WindowTitle = $scriptName


# test na prikaz "robocopy" je v adresari C:windows\system32 ( tedy v $PATH )
$c1 ="robocopy"
#$c1 = "robocopyXXX" # testovaci radek
if (-not (Get-Command $c1 -ErrorAction SilentlyContinue )) {
Write-Warning "prikaz $c1 nenalezen"
sleep 5
exit 1
}

$cekej = 10
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
"E20312161846" #  320 Gb bilej box Hdd, zatim vynechano, slozi pro historii souboru sluzba windows 10
)


Write-Host -ForegroundColor Cyan "program pro automatickou synchronizaci na ruzne USB jednotky"
$d_pole_usb_sn = $pole_usb_sn.Length
echo "celkem registrovanych USB jednotek - $d_pole_usb_sn" # pocet registrovanych SN jednotek 

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

# ulozi do objektu
$results += [PSCustomObject]@{
DriveLetter = $ld.DeviceID
Model = $d.Model
HardwareSN = $d.SerialNumber
DeviceID = $d.DeviceID
SizeGb = $d.Size
}}}}

#echo $results
$d_results = $results.Length
echo "celkovy nalezenych pocet pripojenych USB jednotek - $d_results"
echo ""

for ( $aa = 0; $aa -le $d_results -1; $aa++ ) {
$jednotka_pismeno = $results[$aa].DriveLetter
$jednotka_model = $results[$aa].Model
$jednotka_sn = $results[$aa].HardwareSN
$jednotka_size = $results[$aa].SizeGb


# pridano 3.4.2026, zobrazuje velikost jednotky v bytech 
#Write-Host -ForegroundColor Red $jednotka_size
#Write-Host -ForegroundColor Red $jednotka_size.GetTypeCode() # UInt64 - SD karta 32 Gb

# # upraveno 3.4.2026
# presunuto sen, bude spolecne pro vsechny a bude senulovat po kazdem pruchdu for $aa cykem
$s = 0 # vynulovani prommenne $s z predchoziho pruchodu for cyklem $aa
# (pri prvnim pruchodu naopak deklarovani,zbytecne ale musi byt
$s = [Math]::Ceiling( $jednotka_size / 1000000000 ) # spolecne pro vsechny

# pro 16 GB ( zlute )
if (
( $jednotka_sn -like $pole_usb_sn[0] ) -or 
( $jednotka_sn -like $pole_usb_sn[1] )
) {

Write-Host -ForegroundColor Yellow "$jednotka_pismeno $s GB, $jednotka_model, SN - $jednotka_sn"
sleep $cekej

Copy-Item C:\Users\DELL\Documents\dvd $jednotka_pismeno\RoboCopy\dvd # -Confirm -force
Copy-Item C:\Users\DELL\Documents\dvd $jednotka_pismeno\dvd

robocopy "C:\Users\DELL\Documents\QL_SAVE" "$jednotka_pismeno\RoboCopy\QL_SAVE" *.* /MIR
robocopy "C:\Users\DELL\Documents\Lua52_Win32" "$jednotka_pismeno\RoboCopy\Lua52_Win32" *.* /MIR
robocopy "C:\Users\DELL\Documents\ubuntu" "$jednotka_pismeno\RoboCopy\ubuntu" *.* /MIR
robocopy "C:\Users\DELL\Documents\Dev-Cpp" "$jednotka_pismeno\RoboCopy\Dev-Cpp" *.* /MIR
robocopy "C:\Users\DELL\Documents\ps1" "$jednotka_pismeno\RoboCopy\ps1" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\iso" "$jednotka_pismeno\RoboCopy\iso" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\termux_backup" "$jednotka_pismeno\RoboCopy\termux_backup" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\bordel" "$jednotka_pismeno\RoboCopy\bordel" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\login" "$jednotka_pismeno\RoboCopy\login" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\login" "$jednotka_pismeno\login" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\dvd_katalog" "$jednotka_pismeno\RoboCopy\dvd_katalog" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\dvd_katalog" "$jednotka_pismeno\dvd_katalog" *.* /MIR

robocopy "C:\Users\DELL\Documents\zaloha\segway_kolobezka_moje" "$jednotka_pismeno\RoboCopy\segway_kolobezka_moje" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\ruzne" "$jednotka_pismeno\RoboCopy\ruzne" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\moje_prace" "$jednotka_pismeno\RoboCopy\moje_prace" *.* /MIR

$datum = "{0:dd.MM.yyyy HH:mm:ss}" -f (Get-Date)
#echo $datum
Set-Content -Path "$jednotka_pismeno\Robocopy\last_sync_time-date_info.txt" -Encoding ASCII -Value $datum
}


# pro 32 Gb ( blede modre ) ale pro pro SD kartu v redukci
if ( $jednotka_sn -like $pole_usb_sn[2] ) {

Write-Host -ForegroundColor Yellow "$jednotka_pismeno $s GB, $jednotka_model, SN - $jednotka_sn"
sleep $cekej

Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\RoboCopy\dvd" -force # -Confirm -force
Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\dvd" -Force

robocopy "C:\Users\DELL\Documents\zaloha\dvd_katalog" "$jednotka_pismeno\dvd_katalog" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\login" "$jednotka_pismeno\login" *.* /MIR

# robocopy "C:\Users\DELL\Documents" "$jednotka_pismeno\RoboCopy\Documents" *.* /MIR
robocopy "C:\Users\DELL\Documents" "$jednotka_pismeno\RoboCopy\Documents" *.* /MIR /XD "C:\Users\DELL\Documents\zaloha\vypalit_na_BD"

# /XD exclude directory "C:\Users\DELL\Documents\Visual Studio 2022" FYNGUJE, VYZKOUSENO
# REM v adresari "Documents" vynecha slozku "Visual Studio 2022"

$datum = "{0:dd.MM.yyyy HH:mm:ss}" -f (Get-Date)
#echo $datum
Set-Content -Path "$jednotka_pismeno\Robocopy\last_sync_time-date_info.txt" -Encoding ASCII -Value $datum
}


# pro 64 Gb ( modre )
if ( $jednotka_sn -like $pole_usb_sn[4] ) {
Write-Host -ForegroundColor Yellow "$jednotka_pismeno $s GB, $jednotka_model, SN - $jednotka_sn"
sleep $cekej

Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\RoboCopy\dvd" -force # -Confirm -force
Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\dvd" -Force

robocopy "C:\Users\DELL\Documents\zaloha\dvd_katalog" "$jednotka_pismeno\dvd_katalog" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\login" "$jednotka_pismeno\login" *.* /MIR

robocopy "C:\Users\DELL\Documents" "$jednotka_pismeno\RoboCopy\Documents" *.* /MIR

robocopy "C:\Users\DELL\Pictures" "$jednotka_pismeno\RoboCopy\Pictures" *.* /MIR
robocopy "C:\Users\DELL\Videos" "$jednotka_pismeno\RoboCopy\Videos" *.* /MIR

$datum = "{0:dd.MM.yyyy HH:mm:ss}" -f (Get-Date)
#echo $datum
Set-Content -Path "$jednotka_pismeno\Robocopy\last_sync_time-date_info.txt" -Encoding ASCII -Value $datum
}


# ostatni vice nez 64 Gb ( cervene ) 
if ((
( $jednotka_sn -like $pole_usb_sn[5] ) -or
( $jednotka_sn -like $pole_usb_sn[7] ) -or
( $jednotka_sn -like $pole_usb_sn[8] ) # novinka rozdeleni vice podminek na vice radku :) ( prehlednejsi reseni )
)) {

Write-Host -ForegroundColor Yellow "$jednotka_pismeno $s GB, $jednotka_model, SN - $jednotka_sn"
sleep $cekej

Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\RoboCopy\dvd" -force # -Confirm -force
Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\dvd" -Force

robocopy "C:\Users\DELL\Documents\zaloha\dvd_katalog" "$jednotka_pismeno\dvd_katalog" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\login" "$jednotka_pismeno\login" *.* /MIR

robocopy "C:\Users\DELL\Documents" "$jednotka_pismeno\RoboCopy\Documents" *.* /MIR

robocopy "C:\Users\DELL\Pictures" "$jednotka_pismeno\RoboCopy\Pictures" *.* /MIR
robocopy "C:\Users\DELL\Videos" "$jednotka_pismeno\RoboCopy\Videos" *.* /MIR
robocopy "C:\Users\DELL\Music" "$jednotka_pismeno\RoboCopy\Music" *.* /MIR

# date /t > E:\RoboCopy\last_sync_time-date_info.txt & time/t >> E:\Robocopy\last_sync_time-date_info.txt
$datum = "{0:dd.MM.yyyy HH:mm:ss}" -f (Get-Date)
#echo $datum
Set-Content -Path "$jednotka_pismeno\Robocopy\last_sync_time-date_info.txt" -Encoding ASCII -Value $datum
}

# pouze pro fleska televize ( dela se trochu jinak !, fialove)
if ( $jednotka_sn -like $pole_usb_sn[6] ) {
Write-Host -ForegroundColor Yellow "$jednotka_pismeno $s GB, $jednotka_model, SN - $jednotka_sn"
sleep $cekej

robocopy "C:\Users\DELL\Documents" "$jednotka_pismeno\RoboCopy\Documents" *.* /MIR
robocopy "C:\Users\DELL\Pictures" "$jednotka_pismeno\RoboCopy\Pictures" *.* /MIR
robocopy "C:\Users\DELL\Videos" "$jednotka_pismeno\RoboCopy\Videos" *.* /MIR
robocopy "C:\Users\DELL\Music" "$jednotka_pismeno\RoboCopy\Music" *.* /MIR

$datum = "{0:dd.MM.yyyy HH:mm:ss}" -f (Get-Date)
#echo $datum
Set-Content -Path "$jednotka_pismeno\Robocopy\last_sync_time-date_info.txt" -Encoding ASCII -Value $datum
}

# pridano 2.4.2026
# GPS-ka, Garminm vnitni pamet cca. 2GB
if ( $jednotka_sn -like $pole_usb_sn[9] ) {
Write-Host -ForegroundColor Yellow "$jednotka_pismeno $s GB, $jednotka_model, SN - $jednotka_sn"
sleep $cekej
robocopy "$jednotka_pismeno\" "C:\Users\DELL\Documents\zaloha\GPS-ka\" *.* /MIR

$datum = "{0:dd.MM.yyyy HH:mm:ss}" -f (Get-Date)
#echo $datum
Set-Content -Path "C:\Users\DELL\Documents\zaloha\GPS-ka\last_sync_time-date_info.txt" -Encoding ASCII -Value $datum
}

# pridano 3.4.2026
# SD karta 32 Gb v redukci, vyhodnocuje se i velikost karty - 31914086400 - UInt63
if (
( $jednotka_sn -like $pole_usb_sn[3] ) -and # tady misto -or musi byt -and (obe podminky musi byt splneny, ne jedna znich)
( $jednotka_size -eq 31914086400  ) # type Uint64, upraveno 3.4.2026
) {
Write-Host -ForegroundColor Yellow "$jednotka_pismeno $s GB, $jednotka_model, SN - $jednotka_sn"
#echo "yyyyyyyyyyyyyyyyy"
sleep $cekej

Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\RoboCopy\dvd" -force # -Confirm -force
Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\dvd" -Force

robocopy "C:\Users\DELL\Documents\zaloha\dvd_katalog" "$jednotka_pismeno\dvd_katalog" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\login" "$jednotka_pismeno\login" *.* /MIR

# robocopy "C:\Users\DELL\Documents" "$jednotka_pismeno\RoboCopy\Documents" *.* /MIR
robocopy "C:\Users\DELL\Documents" "$jednotka_pismeno\RoboCopy\Documents" *.* /MIR /XD "C:\Users\DELL\Documents\zaloha\vypalit_na_BD"

# /XD exclude directory "C:\Users\DELL\Documents\Visual Studio 2022" FYNGUJE, VYZKOUSENO
# REM v adresari "Documents" vynecha slozku "Visual Studio 2022"

$datum = "{0:dd.MM.yyyy HH:mm:ss}" -f (Get-Date)
#echo $datum
Set-Content -Path "$jednotka_pismeno\Robocopy\last_sync_time-date_info.txt" -Encoding ASCII -Value $datum
}

# SD karta 4Gb v redukci
# SN je cislem redukce samotne, nikolov SD karty v redukci takze je potreba vyhodnotit jeste velikost karty cca. 4GB

if (
( $jednotka_sn -like $pole_usb_sn[3] ) -and # # pridano 3.4.2026
( $jednotka_size -eq 4022161920 ) # Uint64, 4GB Sd karta v redukci
) {
Write-Host -ForegroundColor Yellow "$jednotka_pismeno $s GB, $jednotka_model, SN - $jednotka_sn"
#echo "zzzzzzzzzzzzzzzz"
sleep $cekej

#robocopy "$jednotka_pismeno\" "C:\Users\DELL\Documents\zaloha\GPS-ka\" *.* /MIR
Copy-Item "C:\Users\DELL\Documents\dvd" "$jednotka_pismeno\dvd" -Force

Copy-Item "C:\Users\DELL\Documents\zaloha\bookmarks.html" "$jednotka_pismeno\bookmarks.html" -Force
Copy-Item "C:\Users\DELL\Documents\zaloha\bookmarks.json" "$jednotka_pismeno\bookmarks.json" -Force
Copy-Item "C:\Users\DELL\Documents\zaloha\firefox_hesla.csv" "$jednotka_pismeno\firefox_hesla.csv" -Force
Copy-Item "C:\Users\DELL\Documents\zaloha\firefox_hesla.rar" "$jednotka_pismeno\firefox_hesla.json" -Force
Copy-Item "C:\Users\DELL\Documents\zaloha\login.rar" "$jednotka_pismeno\login.rar" -Force
Copy-Item "C:\Users\DELL\Documents\zaloha\registr.rar" "$jednotka_pismeno\registr.rar" -Force

robocopy "C:\Users\DELL\Documents\zaloha\login" "$jednotka_pismeno\RoboCopy\login" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\ruzne" "$jednotka_pismeno\RoboCopy\ruzne" *.* /MIR
robocopy "C:\Users\DELL\Documents\zaloha\moje_prace" "$jednotka_pismeno\RoboCopy\moje_prace" *.* /MIR

$datum = "{0:dd.MM.yyyy HH:mm:ss}" -f (Get-Date)
#echo $datum
Set-Content -Path "C:\Users\DELL\Documents\zaloha\GPS-ka\last_sync_time-date_info.txt" -Encoding ASCII -Value $datum
}



# konec prikazu for $aa
echo ""
}

Read-Host -Prompt "Press ENTER to continue . . ."
sleep 1

