echo "Starting the script"

n_commit=200

apiKey="MTpEbzhXQThOaW14bHVQTVdZZXNBTTVLT0xhZ00"
#fileName="/f/professional/projects/java/appsurify/jsoup/target/surefire-reports/TEST-org.jsoup.helper.DataUtilTest.xml"
project="jsoup"
testsuite="Unit"
importtype="junit"
#commitId="9f2f5671674e4fdbaea3bf73e826354fb177111b"

> console.log



for j in `git branch -r | grep origin | grep -v HEAD`
do
    echo "branch" >> console.log
    echo $j >> console.log
	git checkout $j
    for i in `git log -n $n_commit --reverse | grep commit | cut -d " " -f2`
    do
      echo $i >> console.log
	  commitId=$i
      git checkout $i

      echo "running test" >> console.log
      C:/apache/apache-maven-3.5.0/bin/mvn test

	  echo "push test results to api server" >> console.log
	  
	  for fileName in `ls -1 ./target/surefire-reports/*.xml`
	  do
	    echo "call api for $fileName" >> console.log
      echo $commitId
      echo $fileName
		  curl -X POST http://appsurify.test.appsurify.com/api/external/import/ -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' -H "token: $apiKey" -F "file=@$fileName" -F 'project_name'=$project -F 'test_suite_name'=$testsuite -F 'type'=$importtype -F 'commit'=$commitId
	  done	  
    done
done


