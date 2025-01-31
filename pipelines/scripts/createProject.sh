#!/bin/bash

#############################################################################
#                                                                           #
# createProject.sh : Creates Project if does not exists                     #
#                                                                           #
#############################################################################

LOCAL_DEV_URL=$1
admin_user=$2
admin_password=$3
project=$4
debug=${@: -1}

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

    if [ -z "$project" ]; then
      echo "Missing template parameter repoName"
      exit 1
    fi

 if [ "$debug" == "debug" ]; then
    echo "......Running in Debug mode ......"
  fi


function echod(){
  
  if [ "$debug" == "debug" ]; then
    echo $1
  fi

}


PROJECT_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${project}

echo "Check Project exists"
echo "Project name is ${project} and admin user is ${admin_user} and pwd is ${admin_password}"
name=$(curl --location --request GET ${PROJECT_URL} \
        --header 'Accept: application/json' \
        -u ${admin_user}:${admin_password} | grep -o '"name":"[^"]' | grep -o '[^"]$')
echo "name of project in webmio '${name}'"
if [ -z "$name" ];   then
    echo "Project does not exists. Creating ..."
    #### Create project in the tenant
   PROJECT_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects
   ## PROJECT_URL=${LOCAL_DEV_URL}/projects
   echo "Project name is '${project}'"
    json='{"name": "'${project}'", "description": "Created by Automated CI for feature branch"}'
    echo "Project url is ${PROJECT_URL}"
    echo "json is ${jsonString}"
    projectName=$(curl --location --request POST ${PROJECT_URL} \
    --header "Content-Type:application/json" \
    --header "Accept:application/json" \
    --data-raw '{"name": "'${project}'", "description": "Created by Automated CI for feature branch"}' -u ${admin_user}:${admin_password})

    echo "Project name is ${projectName}"
    
    namecreated=$(echo "$projectName" | grep -o '"name":"[^"]' | grep -o '[^"]$')
    echo "Name created is ${namecreated}"
    
    if [ ! -z "$namecreated" ]; then
        echo "Project created successfully:" ${projectName}
    else
        echo "Project creation failed:" ${projectName}
        exit 1
    fi
else
    echo "Project already exixts with name:" ${name}
    exit 0
fi
