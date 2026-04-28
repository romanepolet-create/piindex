$target = "0768676905"

for ($i=1; $i -le 1000000000; $i+=100000000) {
  $start = $i
  $end = $i + 99999999
  $zip = "pi_${start}_${end}.zip"
  $folder = "pi_$start"

  Invoke-WebRequest -Uri "https://files.pilookup.com/pi/$start-$end.zip" -OutFile $zip
  Expand-Archive $zip -DestinationPath $folder

  $result = Select-String -Path ".\$folder\*.txt" -Pattern $target

  if ($result) {
    Write-Host "FOUND in range $start-$end"
    break
  }

  Remove-Item $zip
  Remove-Item $folder -Recurse -Force
}
