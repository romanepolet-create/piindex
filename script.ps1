$target = "0768676905"
# Read progress from the repo file
$startValue = [int](Get-Content "progress.txt")

# Set a limit on how many loops to do per GitHub Action run
# You'll have to test this to see how many it can do in ~5 hours
$loopsPerRun = 10 
$currentLoop = 0

for ($i = $startValue; $i -le 1000000000; $i += 100000000) {
    if ($currentLoop -ge $loopsPerRun) {
        Write-Host "Chunk finished, saving progress for next run..."
        break
    }

    $start = $i
    $end = $i + 99999999
    $zip = "pi_${start}_${end}.zip"
    $folder = "pi_$start"

    # ... your download, extract, and search logic goes here ...
    # (Keep your Invoke-WebRequest, Expand-Archive, Select-String)

    if ($result) {
        Write-Host "FOUND in range $start-$end"
        # Optional: write the success to a file and push that too!
        exit
    }

    # Clean up
    Remove-Item $zip -ErrorAction SilentlyContinue
    Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue

    $currentLoop++
    
    # Save the NEXT starting number to the file
    $nextStart = $i + 100000000
    $nextStart | Out-File "progress.txt"
}
