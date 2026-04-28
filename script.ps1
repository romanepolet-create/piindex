$ErrorActionPreference = "Stop"

$target = "0768676905"
# Read progress from the repo file
$startValue = [int](Get-Content "progress.txt")

# Set a limit on how many loops to do per GitHub Action run
$loopsPerRun = 10 
$currentLoop = 0

# Limit increased to 100 Billion so it doesn't stop too early!
for ($i = $startValue; $i -le 100000000000; $i += 100000000) {
    if ($currentLoop -ge $loopsPerRun) {
        Write-Host "Chunk finished, saving progress for next run..."
        break
    }

    $start = $i
    $end = $i + 99999999
    $zip = "pi_${start}_${end}.zip"
    $folder = "pi_$start"

    Write-Host "Downloading $zip..."
    Invoke-WebRequest -Uri "https://files.pilookup.com/pi/$start-$end.zip" -OutFile $zip
    
    Write-Host "Extracting $zip..."
    Expand-Archive $zip -DestinationPath $folder
    
    Write-Host "Searching for $target..."
    $result = Select-String -Path ".\$folder\*.txt" -Pattern $target

    if ($result) {
        Write-Host "FOUND in range $start-$end"
        
        # Write the success message to a file
        $message = "🎉 SUCCESS! The target $target was found in the zip file: pi_${start}_${end}.zip"
        $message | Out-File "SUCCESS.txt"
        
        # Exit the script immediately
        exit
    }

    # Clean up (Deletes the files)
    Write-Host "Cleaning up files..."
    Remove-Item $zip -ErrorAction SilentlyContinue
    Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue

    $currentLoop++
    
    # Save the NEXT starting number to the file
    $nextStart = $i + 100000000
    $nextStart | Out-File "progress.txt"
}
