#!/bin/bash

        groupIdLocal=$1
        artifactIdLocal=$2
        majorMinorLocal=$3
	username=$4
	pwd=$5

        groupIdPath=${groupId//.//}

        echo $groupId
        echo $artifactId
        echo $majorMinor
    

        echo $groupIdLocal
        echo $artifactIdLocal
        echo $majorMinorLocal
	echo $username
	
	DATOS=$(curl -u "$env.ARTIFACTORY_USER:$env.ARTIFACTORY_PASS" "http://artifactory:8081/artifactory/api/search/versions?g=$groupIdLocal&a=$artifactIdLocal&repos=libs-release-local")
        #DATOS="${curl http://localhost:8081/artifactory/api/search/versions?g=$groupIdLocal&a=$artifactIdLocal&repos=libs-release-local}"

        echo $DATOS


        VERSIONS_TO_REMOVE=$(echo $DATOS | jq "[{version: .results | .[] | select(.version | startswith($majorMinorLocal | tostring)) | .version}] | sort | .[:-2]")


        for row in $(echo "$VERSIONS_TO_REMOVE" | jq -r '.[] | @base64'); do
                _jq(){
                        echo ${row} | base64 --decode | jq -r ${1}
                }

                version_to_remove=$(echo $(_jq '.version'))
                curl -i -X DELETE -u "${username}:${pwd}" 'http://artifactory:8081/artifactory/libs-release-local/'$groupIdPath'/'$artifactId'/'$version_to_remove
        done


