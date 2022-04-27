
#export JAVA_HOME="/c/Program Files/Java/jdk1.8.0_161"

parentpath="c:/Github/jsoup2/"
srcpath="c:/Github/jsoup2/src/main/java"
cpath="c:/Github/jsoup2/target/classes"

#apiKey="MTpEbzhXQThOaW14bHVQTVdZZXNBTTVLT0xhZ00"
#project="121"
#testsuite="Unit"
#importtype="junit"

apiKey="NDA6X1ZfQml1SUlKek1FNzQ1Rll3aDd1RHR0MDRuRWN3WEl3emVERHFZZlVJUQ"
#fileName="/f/professional/projects/java/appsurify/jsoup/target/surefire-reports/TEST-org.jsoup.helper.DataUtilTest.xml"
project="Jsoup"
testsuite="Unit"
importtype="junit"

total=1
counter=0
echo "hello"
num=0

numdetails=`find . -name "details.txt" -print | wc -l`
echo $numdetails
randomnum=$(((RANDOM%$numdetails)+1))

find . -name "details.txt" -print | while read filename
do
    #echo "start ..."
	((num++))
    if [ $counter -eq $total ]
    then
	  break;
    fi

	if [ $num -ne $randomnum ];
	then
	    #echo "random skipping ... "
		continue
	fi
	
	#foo=$RANDOM
    
	#if [ $((foo%2)) -eq 0 ];
	#if [ $((foo%100)) -gt 0 ];
	#then
	#    echo "random skipping ... "
	#	continue
	#fi


	echo $filename

	dir=`dirname $filename`
	classname=`ls -1 $dir/*.class | xargs basename`
	echo $classname

	javafile=`echo "$classname" | sed 's/\./\//g' | sed 's/\/class/\.java/g' `
	javafile=${javafile%\.*}
	javafile=${javafile%\$*}
	echo "JAVA FILE = "
	echo $javafile
	javafile=`echo "$javafile".java`
	completepath=$srcpath/$javafile
	echo $completepath
	
	cfile=`echo "$javafile" | sed 's/java/class/g' `
	echo $cpath/$cfile

	jname=`echo $completepath | xargs basename`
	newfile=`echo $completepath | xargs basename`
	newfile=`echo "$newfile"new`
    echo $dir/$newfile 

	echo ""
	echo "#################"
	echo "Stored data name = " "$dir/$jname"
	echo "############"
	echo "copying java file"

	# Replace the .java file
	echo "$dir/$newfile" $completepath
	cp "$dir/$newfile" $completepath
	EXIT_STATUS=$?
	
	if [ $EXIT_STATUS -ne 0 ]; then
        echo "Continue to next file ..........."
		continue 
	fi
	
	# replace the .class
	echo "$dir/$classname" "$cpath/$cfile"
	cp "$dir/$classname" "$cpath/$cfile"
	
	echo "running test"
	# run mvn surefire:test
	cd $parentpath
	#/g/installations/maven/apache-maven-3.5.4-bin/apache-maven-3.5.4/bin/mvn surefire:test
	mvn surefire:test

	# commit the code
	git add -A
	git status
	git commit -m "mutant changes"
    git push
	
	commitId=`git log -n 1 | grep commit | cut -d " " -f2`
	sleep 60
	
	# push the results
	echo "push test results to api server"
	#fileName="/f/professional/projects/java/appsurify/mutant_project/git_repo/jsoup/target/surefire-reports/TEST-org.jsoup.select.TraversorTest.xml"
	
	for fileName in `ls -1 ./target/surefire-reports/*.xml`
	  do
	    echo "call api for $fileName" 
		curl -X POST https://demo.appsurify.com/api/external/import/ -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' -H "token: $apiKey" -F "file=@$fileName" -F 'project_name'=$project -F 'test_suite_name'=$testsuite -F 'type'=$importtype -F 'commit'=$commitId
	  done
	
	cd ..
	echo "-----Revert the java file------------"
	
	# Replace the .java file
	#echo "replacing .java file"
	#echo "$dir/$jname" $completepath
	#cp "$dir/$jname" $completepath
	git revert HEAD --no-edit

	
	# replace the .class  or mvn clean install
	cd $parentpath
	CHDIR
	git revert HEAD --no-edit
	#mvn clean install
	#/g/installations/maven/apache-maven-3.5.4-bin/apache-maven-3.5.4/bin/mvn clean install
	
	# run mvn surefire:test
	#/g/installations/maven/apache-maven-3.5.4-bin/apache-maven-3.5.4/bin/mvn surefire:test
	mvn test

	# commit the code
	#git add -A
	#git status
	#git commit -m "revert mutant changes"
    git push
	
	commitId=`git log -n 1 | grep commit | cut -d " " -f2`
	sleep 60
	
	# push the results
	echo "push test results to api server"
	#fileName="/f/professional/projects/java/appsurify/mutant_project/git_repo/jsoup/target/surefire-reports/TEST-org.jsoup.select.TraversorTest.xml"
	
	for fileName in `ls -1 ./target/surefire-reports/*.xml`
	  do
	    echo "call api for $fileName" 
		curl -X POST https://demo.appsurify.com/api/external/import/ -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' -H "token: $apiKey" -F "file=@$fileName" -F 'project_name'=$project -F 'test_suite_name'=$testsuite -F 'type'=$importtype -F 'commit'=$commitId
	  done
	
	cd ..
	
	echo "----------------"
	
	
	((counter++))
	echo $counter
	echo "---------------------------------------------------------------------------"

done
