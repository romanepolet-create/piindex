$ErrorActionPreference = "Stop"
Write-Host "🚀 Script is starting up..."

# Read progress
$rawText = Get-Content "progress.txt"
Write-Host "Raw text found in progress.txt: $rawText"

$startValue = [int]$rawText
Write-Host "Starting search at number: $startValue"

$loopsPerRun = 10 
$currentLoop = 0

for ($i = $startValue; $i -le 100000000000; $i += 100000000) {
    if ($currentLoop -ge $loopsPerRun) {
        Write-Host "🛑 Chunk finished, saving progress for next run..."
        break
    }

    $start = $i
    $end = $i + 99999999
    $zip = "pi_${start}_${end}.zip"
    $folder = "pi_$start"

    Write-Host "⬇️ Downloading $zip..."
    Invoke-WebRequest -Uri "https://files.pilookup.com/pi/$start-$end.zip" -OutFile $zip
    
    Write-Host "📦 Extracting $zip..."
    Expand-Archive $zip -DestinationPath $folder
    
    Write-Host "🔍 Searching for target..."
    $result = Select-String -Path ".\$folder\*.txt" -Pattern "0768676905"

    if ($result) {
        Write-Host "🚨 FOUND IN RANGE $start-$end! 🚨"
        $message = "🎉 SUCCESS! The target 0768676905 was found in the zip file: pi_${start}_${end}.zip"
        $message | Out-File "SUCCESS.txt"
        exit
    }

    Write-Host "🗑️ Cleaning up files..."
    Remove-Item $zip -ErrorAction SilentlyContinue
    Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue

    $currentLoop++
    
    $nextStart = $i + 100000000
    $nextStart | Out-File "progress.txt"
    Write-Host "✅ Saved $nextStart to progress.txt"
}
