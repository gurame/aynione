nuget restore ./packages.tools.config -OutputDirectory ./Packages
dotnet build -c  Debug
OpenCover.Console.exe -target:".\dotnet.exe" -targetargs:"test ./tests/aynione.unittest/aynione.unittest.csproj" -register:user -filter:"+[aynione*]*" -oldStyle -output:./coverage.xml 
$coveralls = (Resolve-Path "./Packages/coveralls.net.*/tools/csmacnz.coveralls.exe").ToString()
$reportgenerator = (Resolve-Path "./Packages/ReportGenerator.*/tools/ReportGenerator.exe").ToString()
write-host "repotoken" $env:COVERALLS_REPO_TOKEN
write-host "commit" $env:APPVEYOR_REPO_COMMIT
write-host "message" $env:APPVEYOR_REPO_COMMIT_MESSAGE
write-host "job id" $env:APPVEYOR_JOB_ID
write-host "branch" $env:APPVEYOR_REPO_BRANCH
write-host "author email" $env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL
& $reportgenerator -reports:"./coverage.xml" -targetdir:coverage -verbosity:Error
#& $coveralls --opencover -i "./coverage.xml" --repoToken "MwCrQHSHjSubfBOeO2FFTxuO5bmdq1Aho" --useRelativePaths
