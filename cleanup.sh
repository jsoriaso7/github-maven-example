  #!/bin/bash
        
        groupId=${groupId}
        artifactId=${artifactId}
        majorminor=${majorMinor}

        groupIdPath=${groupId//.//}
        
    



        DATOS=${curl 'http://admin:Deloitte01@localhost:8081/artifactory/api/search/versions?g='$groupId'&a='$artifactId'&repos=libs-release-local'}

        echo $DATOS


        VERSIONS_TO_REMOVE=$(echo $DATOS | jq '[{version: .results | .[] | select(.version | startswith('$majorminor' | tostring)) | .version}] | sort | .[:-2]')


        for row in $(echo "$VERSIONS_TO_REMOVE" | jq -r '.[] | @base64'); do
	        _jq(){
		        echo ${row} | base64 --decode | jq -r ${1}
        	}

	        version_to_remove=$(echo $(_jq '.version'))
	        curl -i -X DELETE -u admin:Deloitte01 'http://localhost:8081/artifactory/libs-release-local/'$groupIdPath'/'$artifactId'/'$version_to_remove
        done
