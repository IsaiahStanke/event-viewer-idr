Clear-Host # just clearing the terminal

Write-Host ""
Write-Host -ForegroundColor Yellow "This script is used to grab certain Event Viewer ID's (e.g. for IDR, forensics, etc.), it takes multiple variables so please fill them out correctly. Thanks for using it! - Isaiah Stanke"
Write-Host ""

# Getting user input here instead of hardcoding
$eventType = Read-Host "Enter the event log name (e.g., System, Security, Application)"
Write-Host ""
$eventIDs = Read-Host "Enter Event IDs (comma-separated if multiple)"
Write-Host ""
$startDate = Read-Host "Enter the start date (yyyy-MM-dd)"
Write-Host ""
$endDate = Read-Host "Enter the end date (yyyy-MM-dd)"

# Converting strings into DateTime objects so it will understand it
$startDate = [DateTime]::ParseExact($startDate, 'yyyy-MM-dd', $null)
$endDate = [DateTime]::ParseExact($endDate, 'yyyy-MM-dd', $null)

# Parsing the events and removing the comma
$eventIDArray = $eventIDs -split ',' | ForEach-Object { $_.Trim() }


# Grabbing the events in a for loop and goes into if statement
foreach ($eventID in $eventIDArray) {
    try {
        # grabbing the events
        $events = Get-WinEvent -FilterHashtable @{
            LogName = $eventType
            Id = $eventID
            StartTime = $startDate
            EndTime = $endDate
        } 2>$null  # It will still display error code if no events show, so I've pushed it into the null stream to suppress it! 

        # Showing results
        if ($events.Count -eq 0) {
            # this displays if no events were found instead of default ugly error
            Write-Host ""
            Write-Host -ForegroundColor Yellow "No events in $($eventType) found for Event ID $($eventID)"
        } else {
            $eventCount = $events.Count  # Get the count of events
            Write-Host ""
            Write-Host -ForegroundColor Yellow "$eventCount events have been found in the event type $eventType for Event ID: $eventID" # printing number of events found
            Write-Host ""
            $outputToFile = Read-Host "P [Print all found events in current terminal] S [Save to file]" # asking if user wants to save the events to a file or print it
            if($outputToFile -eq "P") {
                foreach ($event in $events) {
                    Write-Host "" # just doing this to print an empty line and have clean output
                    Write-Host "Event Log: $($event.LogName)"
                    Write-Host "Event ID: $($event.Id)"
                    Write-Host "Time Created: $($event.TimeCreated)"
                    Write-Host "Message: $($event.Message)"
                    Write-Host "--------------------------"
                }
            }
            elseif ($outputToFile -eq "S") {
                Write-Host ""
                Write-Host "You've chosen to save the output into a file"
                Write-Host ""
                $outputFilePath = "$env:USERPROFILE\logs.txt" # setting path to save logs.txt file in case user wants to save output to file
                Set-Content -Path $outputFilePath -Value "" # if file exists, then write over it to start empty
                foreach ($event in $events) {
                    $eventInfo = @"
                    Event Log: $($event.LogName)
                    Event ID: $($event.Id)
                    Time Created: $($event.TimeCreated)
                    Message: $($event.Message)
                    --------------------------
"@
                Add-Content -Path $outputFilePath -Value $eventInfo # adding the info
                }
                Write-Host -ForegroundColor Yellow "Events saved to $outputFilePath" # saying where we saved it
            }
            else {
                Write-Host -ForegroundColor Red "Input not valid, terminating."
                exit 
            }
        }
    } catch {
        Write-Host "Error retrieving events for Event ID $($eventID): $_.Exception.Message"
    }
}
