dotnet build -c  Debug
OpenCover.Console.exe -target:".\dotnet.exe" -targetargs:"test ./tests/aynione.unittest/aynione.unittest.csproj" -register:user -filter:"+[aynione*]*" -oldStyle -output:./coverage.xml 
$coveralls = (Resolve-Path "./Packages/coveralls.net.*/tools/csmacnz.coveralls.exe").ToString()
write-host "repotoken" $env:COVERALLS_REPO_TOKEN
write-host "commit" $env:APPVEYOR_REPO_COMMIT
write-host "message" $env:APPVEYOR_REPO_COMMIT_MESSAGE
write-host "job id" $env:APPVEYOR_JOB_ID
& $coveralls --opencover -i coverage.xml --repoToken $env:COVERALLS_REPO_TOKEN --commitId $env:APPVEYOR_REPO_COMMIT --commitBranch $env:APPVEYOR_REPO_BRANCH --commitAuthor $env:APPVEYOR_REPO_COMMIT_AUTHOR --commitEmail $env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL --commitMessage $env:APPVEYOR_REPO_COMMIT_MESSAGE --jobId $env:APPVEYOR_JOB_ID  