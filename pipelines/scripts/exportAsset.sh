#!/bin/bash
#############################################################################
#                                                                           #
# exportAsset.sh : Export asset from a project                    #
#                                                                           #
#############################################################################

LOCAL_DEV_URL=$1
admin_user=$2
admin_password=$3
repoName=$4
assetID=$5
assetType=$6
HOME_DIR=$7
synchProject=$8

    if [ -z "$LOCAL_DEV_URL" ]; then
      echo "Missing template parameter LOCAL_DEV_URL"
      exit 1
    fi
    
    if [ -z "$admin_user" ]; then
      echo "Missing template parameter admin_user"
      exit 1
    fi

    if [ -z "$admin_password" ]; then
      echo "Missing template parameter admin_password"
      exit 1
    fi

    if [ -z "$repoName" ]; then
      echo "Missing template parameter repoName"
      exit 1
    fi

    if [ -z "$assetID" ]; then
      echo "Missing template parameter assetID"
      exit 1
    fi

    if [ -z "$assetType" ]; then
      echo "Missing template parameter assetType"
      exit 1
    fi

    if [ -z "$HOME_DIR" ]; then
      echo "Missing template parameter HOME_DIR"
      exit 1
    fi

function exportAsset(){

LOCAL_DEV_URL=$1
admin_user=$2
admin_password=$3
repoName=$4
assetID=$5
assetType=$6
HOME_DIR=$7

echo ${assetType}

if [[ $assetType = workflow* ]]; then
        echo $assetType
        FLOW_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/workflows/${assetID}/export
        cd ${HOME_DIR}/${repoName}
        mkdir -p ./assets/workflows
        cd ./assets/workflows
        echo "Workflow Export:" ${FLOW_URL}
        ls -ltr
    else
        FLOW_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/flows/${assetID}/export
        cd ${HOME_DIR}/${repoName}
        mkdir -p ./assets/flowservices
        cd ./assets/flowservices
        echo "Flowservice Export:" ${FLOW_URL}
        ls -ltr
    fi    

  
    linkJson=$(curl  --location --request POST ${FLOW_URL} \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -u ${admin_user}:${admin_password})

    downloadURL=$(echo "$linkJson" | jq -r '.output.download_link')
    
    regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
    
    if [[ $downloadURL =~ $regex ]]; then 
       echo "Valid Download link retreived:"${downloadURL}
    else
        echo "Download link retreival Failed:" ${linkJson}
        exit 1
    fi
    downloadJson=$(curl --location --request GET "${downloadURL}" --output ${assetID}.zip)

    FILE=./${assetID}.zip
    if [ -f "$FILE" ]; then
        echo "Download succeeded:" ls -ltr ./${assetID}.zip
    else
        echo "Download failed:"${downloadJson}
    fi

}  
if [ ${synchProject} == true ]; then
  echo "Listing All Assets"
  echo $assetType
  PROJECT_LIST_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/assets

  projectListJson=$(curl  --location --request GET ${PROJECT_LIST_URL} \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -u ${admin_user}:${admin_password})
  
  readarray -t workflowArray < < $(echo "$projectListJson" | jq -r '.output.workflows')

  for item in "${workflowArray[@]}"; do
    #assetID=$(jq --raw-output '.original_name' <<< "$item")
    #assetType="workflow"
    # do your stuff
    echo "Inside Loop"
    echo $item
  done
else
  exportAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${assetID} ${assetType} ${HOME_DIR} 
fi  


