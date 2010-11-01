param($rootDir, $webRootPath, $excludeListFilename, $suiteVersion)

$chapters = get-childitem $rootDir | where-object{$_.mode -match "d"}
$template='
 <testCollection>
  <!-- adding section element if in the future we want to store information about the -->
  <!-- spec structure in this file, for now the section structure is defined in the   -->
  <!-- sections.js file                                                               -->
  </testCollection>'
$templateMasterList='
  <testSuite numTests="" version="" date="">
  </testSuite>'
  
$masterList=[xml]$templateMasterList
$numTests=0
$utf8Encoding = New-Object System.Text.UTF8Encoding
[xml]$excludeList= get-content $excludeListFilename

foreach($chapter in $chapters)
{
    $testsList = [xml] $template
    $sectionEl = $testsList.CreateElement("section")
    $sectionAttr=$testsList.CreateAttribute("name")
    $null=$sectionEl.Attributes.Append($sectionAttr)
    $numTestAttr=$testsList.CreateAttribute("numTests") 
    $null=$sectionEl.Attributes.Append($numTestAttr)
    
    $testEl= $testsList.CreateElement("test")
    $testAttr=$testsList.CreateAttribute("id")
    $null=$testEl.Attributes.Append($testAttr)
    $newSection=$sectionEl.clone()
    $newSection.GetAttributeNode("name").innerText="Chapter - "+$Chapter.Name
    $sourceFiles = get-childitem $chapter.FullName -include *.js -recurse | where-object{$_.mode -notmatch "d"}
    if($sourceFiles -ne $NULL)
    {
        $excluded=0
        foreach($test in $sourceFiles){
        $testName=$test.Name.Remove($test.Name.Length-3)
         if(($testName.length -gt 0) -and ($excludeList.excludeList.SelectNodes("test[@id ='"+$testName+"']").Count -eq 0))
         {
            $newTestEl=$testEl.clone()
            $null=$newTestEl.GetAttributeNode("id").innerText=$testName

            $scriptCode=Get-Content -Encoding UTF8 $test.FullName

            $scriptCodeContent=""
            foreach($line in $scriptCode){
            $scriptCodeContent+=$line+"`r`n"
            }

            
            # remove comments
            $hs5HarnessPos=$scriptCodeContent.IndexOf("ES5Harness")
            $comments=$scriptCodeContent.Substring(0,$hs5HarnessPos) 
            $comments=$comments -replace "(//.*\n|/\*(.|\n)*?\*/)"
            $scriptCodeContent=$scriptCodeContent.Substring($hs5HarnessPos)

            $scriptCodeContent=[Convert]::ToBase64String($utf8Encoding.GetBytes($scriptCodeContent))
            $cdata=$testsList.CreateCDataSection($scriptCodeContent)
            $null=$newTestEl.AppendChild($cdata)
            $null=$newSection.AppendChild($newTestel)
          }
           else
            {
             $excluded++
           }

         }
        $newSection.numTests=($sourceFiles.Length-$excluded ).ToString()
        $null=$testsList.testCollection.AppendChild($newSection)
        $baseDir=$chapters[0].Parent.FullName
        $testGroupPathname=$baseDir+"\"+$chapter.Name+".xml"
        $null=$testsList.Save($testGroupPathname)
        $testGroupEl=$masterList.CreateElement("testGroup")
        $testGroupEl.innerText=$webRootPath+$chapter.Name+".xml"
        $null=$masterList["testSuite"].AppendChild($testGroupEl)
        
        $numTests+= $sourceFiles.Length-$excluded

    }
}
$null=$masterList["testSuite"].GetAttributeNode("numTests").innerText=$numTests
$null=$masterList["testSuite"].GetAttributeNode("version").innerText=$suiteVersion
$null=$masterList["testSuite"].GetAttributeNode("date").innerText=[datetime]::Now.Date.toString("MM/dd/yyyy") 
$null=$masterList.Save($baseDir+"\testcaseslist.xml")
