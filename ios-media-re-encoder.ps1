[CmdletBinding()]
param (
    [string]$DIR,
    [string]$Template,
    [string]$InputFileFormat,
    [string]$OutputFileFormat
)

# Check that ffmpeg is installed:
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "ffmpeg is required but it's not installed. Please install ffmpeg and try again (suggestion: run `choco install -y ffmpeg` as administrator)."
    exit 1
}

# Check that HandBrakeCLI is installed:
if (-not (Get-Command HandBrakeCLI -ErrorAction SilentlyContinue)) {
    Write-Host "HandBrakeCLI is required but it's not installed. Please install HandBrakeCLI and try again (suggestion: run `choco install -y handbrake-cli` as administrator)."
    exit 1
}

# Set default values for parameters
if (-not $Template) { $Template = "Fast 1080p30" }
if (-not $InputFileFormat) { $InputFileFormat = "mov" }
if (-not $OutputFileFormat) { $OutputFileFormat = "mp4" }

# If template is provided, prompt user to continue or stop
if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Template')) {
    Write-Host "Template provided: $Template"
    Write-Host "Input file format: $InputFileFormat"
    Write-Host "Output file format: $OutputFileFormat"
    $response = Read-Host "Do you want to continue? (y/N)"
    if ($response -ne 'y') {
        Write-Host "Operation cancelled by user."
        exit 1
    }
}

# Check if directory is provided
if (-not $DIR) {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) -DIR <directory> [-Template <template>] [-InputFileFormat <extension>] [-OutputFileFormat <extension>]"
    exit 1
}

# Iterate over all files with the specified input file format in the directory (case insensitive)
$files = Get-ChildItem -Path $DIR -Filter *.$InputFileFormat -Recurse

if ($files.Count -eq 0) {
    Write-Host "No .$InputFileFormat files found in the directory."
    exit 1
}

function Set-EarliestDate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Extract creation and last modified dates:
    $creationDate = (Get-ItemProperty -Path $FilePath).CreationTime
    $modifiedDate = (Get-ItemProperty -Path $FilePath).LastWriteTime

    if ($null -eq $creationDate -or $null -eq $modifiedDate) {
        Write-Host "Error: Unable to retrieve creation or last modified date for $FilePath"
        exit 1
    } elseif ($creationDate -eq $modifiedDate) {
        Write-Output "Creation and modified dates are the same for $FilePath"
        return
    }

    $creationDateEpoch = [DateTimeOffset]::new($creationDate).ToUnixTimeSeconds()
    $modifiedDateEpoch = [DateTimeOffset]::new($modifiedDate).ToUnixTimeSeconds()

    # Determine the earlier date:
    if ($creationDateEpoch -lt $modifiedDateEpoch) {
        $earlierDate = $creationDate
        Write-Output "Creation date ($creationDate) is earlier for $FilePath"
    }
    else {
        $earlierDate = $modifiedDate
        Write-Output "Modified date ($modifiedDate) is earlier for $FilePath"
    }

    # Set both creation and last modified dates to the earlier date:
    (Get-Item $FilePath).CreationTime = $earlierDate
    (Get-Item $FilePath).LastWriteTime = $earlierDate
    Write-Output "Set both dates to $earlierDate for file $FilePath"
}

foreach ($original_file in $files) {
    $base_name = [System.IO.Path]::GetFileNameWithoutExtension($original_file.Name)
    $temp_file = Join-Path -Path $DIR -ChildPath "${base_name}_TEMP.$OutputFileFormat"
    $final_file = Join-Path -Path $DIR -ChildPath "${base_name}.$OutputFileFormat"

    # Fix creation date issue:
    Write-Host "Fixing dates for $original_file"
    Set-EarliestDate -FilePath $original_file.FullName

    # Re-encode original to temp file using HandBrakeCLI:
    Write-Host "Converting $original_file to $temp_file"
    & HandBrakeCLI -i $original_file.FullName -o $temp_file --preset $Template

    # Port metadata from original to final file using ffmpeg:
    Write-Host "Copying metadata from $original_file to $temp_file"
    & ffmpeg -i $original_file.FullName -i $temp_file -map 1 -map_metadata 0 -c copy $final_file

    # Remove the temporary file:
    Remove-Item -Path $temp_file
    Write-Host "Created $final_file and removed $temp_file"

    # Calculate and print progress percentage
    $totalFiles = $files.Count
    $processedFiles = [array]::IndexOf($files, $original_file) + 1
    $progressPercentage = [math]::Round(($processedFiles / $totalFiles) * 100, 2)
    Write-Host "Progress: $progressPercentage% ($processedFiles of $totalFiles files processed)"
}
