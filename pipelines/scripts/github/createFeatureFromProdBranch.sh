#!/bin/bash

#################################################################################
#                                                                               #
# createFeatureFromProdBranch.sh : Create Feature Branch from Production Branch #
#                                                                               #
#################################################################################

devUser=$1
featureBranchName=$2
HOME_DIR=$3
repo_user=$4
PAT=$5
repoName=$6
debug=${@: -1}



    if [ -z "$devUser" ]; then
      echo "Missing template parameter devUser"
      exit 1
    fi

    if [ -z "$featureBranchName" ]; then
      echo "Missing template parameter featureBranchName"
      exit 1
    fi

    if [ -z "$HOME_DIR" ]; then
      echo "Missing template parameter HOME_DIR"
      exit 1
    fi

    if [ -z "$repo_user" ]; then
      echo "Missing template parameter repo_user"
      exit 1
    fi
    
    if [ -z "$PAT" ]; then
      echo "Missing template parameter admin_password"
      exit 1
    fi

    if [ -z "$repoName" ]; then
      echo "Missing template parameter repoName"
      exit 1
    fi
   
    if [ "$debug" == "debug" ]; then
      echo "......Running in Debug mode ......"
    fi

set -x
function echod(){
  
  if [ "$debug" == "debug" ]; then
    echo $1
    
  fi

}
              echo $(pwd)
              echo $(ls -ltr)
              export GPG_TTY=/dev/tty2
              echo $(GPG_TTY)
              # Creating Feature Branch 
              echo "Branch does not exists. Creating Branch ..."
              git config user.email "noemail.com"
              git config user.name "${devUser}"
              git fetch --all
             git checkout -b ${featureBranchName} origin/production
          #    git branch ${featureBranchName} origin/production
              git add .
              git commit -m "Synching from Prod for feature branch ${featureBranchName}"
              git remote -v
              git remote add origin https://github.com/${repo_user}/webmethods_io_int_cicd.git
              git push -u origin ${featureBranchName}
            #  git push git@github.com/${repo_user}/${repoName}.git

set +x
