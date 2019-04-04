#!/bin/bash


        groupIdPath=${groupId//.//}
	
	DATOS=$(curl -u "$usernameCreds:$passwordCreds" "http://artifactory:8081/artifactory/api/search/versions?g=$groupId&a=$artifactId&repos=libs-release-local")
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


