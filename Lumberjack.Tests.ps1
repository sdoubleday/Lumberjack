<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psd1'
$scriptBody = "using module $here\$sut"
$script = [ScriptBlock]::Create($scriptBody)
. $script

Describe "Lumberjack" {
    Context "Lumberjack Filtering" {

        BeforeAll {

            $lj = [Lumberjack]::NEW()
            
            $lj.AddLog($(New-Object-Log-MessageTags -Message “Msg1” -Tags @(“BobTag”,”SueTag”) ))

            $lj.AddLog($(New-Object-Log-MessageTags -Message “Msg2” -Tags @(“BobTag”,”JayTag”) ))

            $lj.AddLog($(New-Object-Log-MessageTags -Message “Msg3” -Tags @(“JayTag”,”SueTag”) ))

            $lj.Logs | Out-String | Write-Verbose -Verbose

        } <# END BeforeAll #>

        #should return an array of logs
        IT '$lj.FilterByTags(@(“BobTag”)).Count | Should Be 2' {
        $lj.FilterByTags(@(“BobTag”)).Count | Should Be 2 }

        IT '$lj.FilterByTags(@(“BobTag”,”SueTag”)).Count | Should Be 1' {
        $lj.FilterByTags(@(“BobTag”,”SueTag”)).Count | Should Be 1 }

        IT '$lj.FilterByTags(@(“BobTag”,”SueTag”,”JayTag”)).Count | Should Be 0' {
        $lj.FilterByTags(@(“BobTag”,”SueTag”,”JayTag”)).Count | Should Be 0}

        IT '$lj.FilterByTags(@(“BobTag”,”BobTag”)).Count | Should Be 2' {
        $lj.FilterByTags(@(“BobTag”,”BobTag”)).Count | Should Be 2}
    
    
    }<# END Context "Lumberjack Filtering" #>

}
