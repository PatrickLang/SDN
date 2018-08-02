Param(
    [parameter(Mandatory = $false)] [string] $Network = "L2Bridge"
)

$BaseDir = "c:\k\debug"
md $BaseDir -ErrorAction Ignore

Invoke-WebRequest -UseBasicParsing  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/windows/debug/dumpVfpPolicies.ps1" -OutFile $BaseDir\dumpVfpPolicies.ps1
Invoke-WebRequest -UseBasicParsing  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/windows/hns.psm1" -OutFile $BaseDir\hns.psm1
Invoke-WebRequest -UseBasicParsing  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/windows/debug/startpacketcapture.cmd" -OutFile $BaseDir\startpacketcapture.cmd
Invoke-WebRequest -UseBasicParsing  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/windows/debug/stoppacketcapture.cmd" -OutFile $BaseDir\stoppacketcapture.cmd

ipmo $BaseDir\hns.psm1

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

$outDir = [io.Path]::Combine($ScriptPath, [io.Path]::GetRandomFileName())
md $outDir
pushd 
cd $outDir

Get-HnsNetwork | Select Name, Type, Id, AddressPrefix > network.txt
Get-hnsnetwork | Convertto-json -Depth 20 >> network.txt

Get-HnsEndpoint | Select Id, IpAddress, MacAddress, IsRemoteEndpoint > endpoint.txt
Get-hnsendpoint | Convertto-json -Depth 20 >> endpoint.txt

Get-hnspolicylist | Convertto-json -Depth 20 > policy.txt

vfpctrl.exe /list-vmswitch-port > ports.txt
powershell $BaseDir\dumpVfpPolicies.ps1 -switchName $Network -outfile vfpOutput.txt

ipconfig /allcompartments /all > ip.txt
route print > routes.txt
popd
Write-Host "Logs are available at $outDir"
