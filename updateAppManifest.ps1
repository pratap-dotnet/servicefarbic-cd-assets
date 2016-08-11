#updateAppManifest.ps1

function Update-AllAssemblyInfoFiles ( $version, $path )
{
    Write-Host "Searching '$path'"
   foreach ($file in "ServiceManifest.xml" ) 
   {
        get-childitem $path -recurse |? {$_.Name -eq $file} | Update-SourceVersion $version ;
   }
   foreach ($file in "ApplicationManifest.xml")
   {
        get-childitem $path -recurse |? {$_.Name -eq $file} | Update-AssemblyManifest $version ;
   }
}


function Update-SourceVersion
{
    Param ([string]$Version)
    foreach ($o in $input) 
    {
        Write-Output "Updating  '$($o.FullName)' -> $Version"
        
        [xml]$serviceManifest = Get-Content -Path $o.FullName -Encoding UTF8

        $serviceManifest.ServiceManifest.Version = $Version
		$serviceManifest.ServiceManifest.CodePackage.Version =$Version
        
		$serviceManifest.ServiceManifest.ConfigPackage.Version = $Version
		
		$serviceManifest.Save($o.FullName)
		
    }
}


function Update-AssemblyManifest
{
    Param ([string]$Version)
    foreach ($o in $input) 
    {
        Write-Output "Updating  '$($o.FullName)' -> $Version"
        
        [xml]$applicationManifest = Get-Content -Path $o.FullName -Encoding UTF8

        $applicationManifest.ApplicationManifest.ApplicationTypeVersion = $Version

        foreach($serviceImport in $applicationManifest.ApplicationManifest.ServiceManifestImport)
        {
           $serviceImport.ServiceManifestRef.ServiceManifestVersion = $Version
        }
        $applicationManifest.Save($o.FullName)
    }
}

# validate arguments 
if ($args -ne $null) {
    $version = $args[0]
    Update-AllAssemblyInfoFiles $version $pwd
}


