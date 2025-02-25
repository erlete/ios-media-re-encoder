# Directory to scan
$directory = $args[0]

# Find all .mov files (case insensitive) in the directory
Get-ChildItem -Path $directory -Filter *.mov -Recurse | ForEach-Object {
    $file = $_.FullName
    Write-Output "Processing $file"

    # Extract creation and last modified dates
    $creationDate = (Get-ItemProperty -Path $file).CreationTime
    $modifiedDate = (Get-ItemProperty -Path $file).LastWriteTime

    # Convert dates to seconds since epoch
    $creationDateEpoch = [DateTimeOffset]::new($creationDate).ToUnixTimeSeconds()
    $modifiedDateEpoch = [DateTimeOffset]::new($modifiedDate).ToUnixTimeSeconds()

    # Determine the earlier date
    if ($creationDateEpoch -lt $modifiedDateEpoch) {
        $earlierDate = $creationDate
        Write-Output "Creation date is earlier"
    } else {
        $earlierDate = $modifiedDate
        Write-Output "Modified date is earlier"
    }

    Write-Output "Setting date: $earlierDate"
    # Set both creation and last modified dates to the earlier date
    (Get-Item $file).CreationTime = $earlierDate
    (Get-Item $file).LastWriteTime = $earlierDate
    Write-Output "Set both dates to $earlierDate"
}