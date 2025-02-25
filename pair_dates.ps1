# Directory to scan
$directory = $args[0]

# Find all .mov files (case insensitive) in the directory
$movFiles = Get-ChildItem -Path $directory -Filter *.mov -Recurse

# Find all .mp4 files (case insensitive) in the directory
$mp4Files = Get-ChildItem -Path $directory -Filter *.mp4 -Recurse

# Create a hashtable to store .mov files by their base name
$movFilesTable = @{}
foreach ($movFile in $movFiles) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($movFile.Name)
    $movFilesTable[$baseName] = $movFile
}

# Process each .mp4 file
foreach ($mp4File in $mp4Files) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($mp4File.Name)
    if ($movFilesTable.ContainsKey($baseName)) {
        $movFile = $movFilesTable[$baseName]
        Write-Output "Processing $movFile and $mp4File"

        # Extract creation and last modified dates from the .mov file
        $creationDate = (Get-ItemProperty -Path $movFile.FullName).CreationTime
        $modifiedDate = (Get-ItemProperty -Path $movFile.FullName).LastWriteTime

        Write-Output "Setting dates for $mp4File"
        # Set both creation and last modified dates of the .mp4 file to the dates from the .mov file
        (Get-Item $mp4File.FullName).CreationTime = $creationDate
        (Get-Item $mp4File.FullName).LastWriteTime = $modifiedDate
        Write-Output "Set both dates to $creationDate and $modifiedDate"
    }
}