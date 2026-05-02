# update as needed, paths assume script is run from project root folder
$Source = "..\docs\1.13 State Regions";

$OutputDirectory = "..\map_data\state_regions\";
$FileOpen = $false;
$StateStart = "^STATE_";
#$StateCount = 0;
#$StatePad = "";

Get-ChildItem -Path $Source -Name |
    ForEach-Object {
        $File = $_;
        $FilePrefix = $File.Substring(0,2)
        $NewSource = Join-Path -Path $Source -ChildPath $File
        Get-Content -Path $NewSource |
            ForEach-Object {
                $Line = $_;
        
                # Check this isn't empty space in between files. If so, skip it.
                if ((-not $FileOpen) -and [string]::IsNullOrWhiteSpace($Line))
                {
                    # We do nothing here, meaning we skip the empty space between files.
                }
                # Check if we've hit a well-formed line that indicates the start of a new message-aligned file.
                elseif ((-not $FileOpen) -and
                        ($Line.Length -gt 6) -and
                        ([regex]::IsMatch($Line.Substring(0, 6), $StateStart)))
                {
                    #if ($StateCount -lt 10) { $StatePad = "0"; }
                    #else { $StatePad = ""; }
                    $Parts = $Line.Split(" ")
                    $NewFileName = [string]::Concat($OutputDirectory, $FilePrefix, "_",
                    # $StatePad, $StateCount, "_",
                     $Parts[0], ".txt");
        
                    Out-File -FilePath $NewFileName -Encoding utf8 -InputObject $Line -ErrorAction:Stop;
                    $FileOpen = $true;
                }
                # Check if we've hit a well-formed line indicating the end of a file.
                elseif ("}" -eq $Line)
                {
                    # This is more of a safety check, since outside of an error condition, $FileOpen should always be $true.
                    if ($FileOpen)
                    {
                        Out-File -FilePath $NewFileName -Encoding utf8 -InputObject $Line -Append;
                    }
        
                    $FileOpen = $false;
                    $NewFileName = $null;
                    #$StateCount = $StateCount + 1;
                }
                # Otherwise, if a file is considered "open", write the line to it. (Mechanically, the file isn't really open - it's just easier to conceptualise it that way.)
                elseif ($FileOpen)
                {
                    Out-File -FilePath $NewFileName -Encoding utf8 -InputObject $Line -Append;
                }
            }
        #$StateCount = 0;
    }
