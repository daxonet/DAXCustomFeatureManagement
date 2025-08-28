$solution = "s"
$solutionFile = (Get-Content "Build\models.sln")
$projectType = ([guid]"FC65038C-1B2F-41E1-A629-BED71D161FFF").toString("B").ToUpper()

$solutionGlobalSection  = [String]"Global`r`n"
$solutionGlobalSection += "	GlobalSection(SolutionConfigurationPlatforms) = preSolution`r`n"
$solutionGlobalSection += "		Debug|Any CPU = Debug|Any CPU`r`n"
$solutionGlobalSection += "	EndGlobalSection`r`n"
$solutionGlobalSection += "	GlobalSection(ProjectConfigurationPlatforms) = postSolution`r`n"

New-Item -ItemType Directory -Path $solution
Get-ChildItem -Path "Metadata" -Directory |
  Foreach-Object {
	$name = $_.Name
	$guid = [guid]::NewGuid().toString("B").ToUpper()
	
	$descriptorFolder = (Join-Path $_.FullName Descriptor)
	$descriptorXml = "$descriptorFolder\$name.xml"
	if(Test-Path -Path $descriptorXml){  
	  (Get-Content "Build\model.rnrproj") | Foreach-Object {
		 $_.replace('{ModelName}', $name).replace('{ProjectGuid}', $guid)
	  } | Set-Content "$solution\$name.rnrproj"
	  
	  $solutionFile += "Project(`"$projectType`") = `"$name`", `"$name.rnrproj`", `"$guid`" "
      $solutionFile += "EndProject"
	  $solutionGlobalSection += "		$guid.Debug|Any CPU.ActiveCfg = Debug|Any CPU`r`n"
	  $solutionGlobalSection += "		$guid.Debug|Any CPU.Build.0 = Debug|Any CPU`r`n"
	}
  }
  
$solutionGlobalSection += "	EndGlobalSection`r`n"
$solutionGlobalSection += "EndGlobal"
$solutionFile += $solutionGlobalSection
$solutionFile | Set-Content "$solution\models.sln"