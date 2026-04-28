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
    $url = "https://files.pilookup.com/pi/$start-$end.zip"
    Write-Host "Attempting URL: $url"
    
    Invoke-WebRequest -Uri $url -OutFile $zip
    
    # --- NEW SAFETY CHECK ---
    $fileSize = (Get-Item $zip).Length
    if ($fileSize -lt 10000000) { # If it's less than 10MB
        Write-Host "❌ ERROR: The downloaded file is fake or empty! Size: $fileSize bytes."
        Write-Host "The URL might be wrong or the server is blocking GitHub."
        Write-Host "Here is what the server actually sent us:"
        Get-Content $zip -TotalCount 15 # Prints the first 15 lines of the fake file
        exit 1 # Kills the script completely
    }
    # ------------------------

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
