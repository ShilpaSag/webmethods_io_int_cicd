##############################################################################
##
## This contains the important Library bash functions that are needed for 
## APIGateway CI/CD process.
## All Library methods in this file use the current directory i.e binary
## as the root directory.
## 
##############################################################################



##############################################################################
##
## Ping an API Gateway Server.
## This checks for the liveliness of the apigateway server 
## by pinging it for a fixed number of iterations.
## The pause time interval for every ping is
## also configurable.
## 
## Usage: ping_apigateway_server <SERVER_URL> <PAUSE_INTERVAL> <ITERATION_COUNT>
##############################################################################
ping_apigateway_server() {

	SERVER=$1
	PAUSE=$2
	ITERATIONS=$3
	HEALTH_URL=rest/apigateway/health

	while true 
	do
		if [ $ITERATIONS -eq 0 ]
		then
			return 0
		fi
		curl -sSf $SERVER/$HEALTH_URL > /dev/null 2>&1
		CS=$?
		if [ $CS -ne 0 ]
		then
			echo "$SERVER is down"
			((ITERATIONS=ITERATIONS-1))
		elif [ $CS -eq 0 ]
		then
			return 1
		fi
		sleep $PAUSE
	done
}

##############################################################################
## Import an API to the API Gateway Server.
## Usage: import_api <api_project> <url> <username> <password>
##############################################################################
import_api() {

	apiName=$1
	wmioapi_url=$2
	admin_user=$3
	admin_password=$4
	BIN_DIR="$PWD"
	CURR_DIR="../"
	API_DIR=$BIN_DIR/iPaas/wmioAPI/

echo "${BIN_DIR} ${api_project} ${url} ${username} ${password} ${CURR_DIR} ${API_DIR} "
 
	if [ -d "$API_DIR" ] 
	then
		## cd $API_DIR && zip -r $CURR_DIR/$apiName.zip ./*
  		cd $API_DIR
		curl -sS -i -X POST $wmioapi_url/rest/apigateway/archive?overwrite=* -H "Content-Type:application/zip" -H"Accept:application/json" --data-binary @"$API_DIR$apiName.zip" -u $admin_user:$admin_password > /dev/null
		## rm $CURR_DIR/$apiName.zip
  		echo "The API $apiName is imported successfully."
	else
		echo "The API with name $apiName does not exist."
	fi
	cd $BIN_DIR
}
##############################################################################
## Import Configurations to the API Gateway Server.
## Usage: import_configurations <configuration_name> <url> <username> <password>
##############################################################################
import_configurations() {

	configuration_name=$1
	url=$2
	username=$3
	password=$4
	stage=$5
	BIN_DIR="$PWD"
	CURR_DIR="../"
	CONF_DIR=$configuration_name
	if [ -d "$CONF_DIR" ] 
	then
		cd $CONF_DIR && zip -r config.zip ./*
		curl -sS -i -X POST $url/rest/apigateway/archive?overwrite=* -H "Content-Type:application/zip" -H"Accept:application/json" --data-binary @"config.zip" -u $username:$password > /dev/null
		rm config.zip
	else
		echo "The Configuration with name $configuration_name does not exists as a flat file."
	fi
	cd $BIN_DIR
}
##############################################################################
## Export an API from the API Gateway Server.
## Usage: export_api <api_project> <url> <username> <password>
##############################################################################
export_api() {
	api_project=$1
	url=$2
	username=$3
	password=$4
	BIN_DIR="$PWD"
	CURR_DIR="../"
	API_DIR=$CURR_DIR/apis/$api_project
	
	if [ -d "$API_DIR" ] 
	then
	curl -s $url/rest/apigateway/archive -d @"$API_DIR/export_payload.json" --output $CURR_DIR/$api_project.zip -u $username:$password -H "x-HTTP-Method-Override:GET" -H "Content-Type:application/json"
	unzip -o $CURR_DIR/$api_project.zip -d $API_DIR/
	rm $CURR_DIR/$api_project.zip
	else
	echo "The API with name $api does not exists in the flat file."
	fi
}
##############################################################################
## Export an API from the API Gateway Server.
## Usage: export_api <api_project> <url> <username> <password>
##############################################################################
export_configurations() {
	configuration_name=$1
	url=$2
	username=$3
	password=$4
	BIN_DIR="$PWD"
	CURR_DIR="../"
	CONF_DIR=$configuration_name
	
	if [ -d "$CONF_DIR" ] 
	then
	curl -s $url/rest/apigateway/archive -d @"$CONF_DIR/export_payload.json" --output config.zip -u $username:$password -H "x-HTTP-Method-Override:GET" -H "Content-Type:application/json"
	unzip -o config.zip -d $CONF_DIR/
	rm config.zip
	else
	echo "The Configuration with name $configuration_name does not exists in the flat file."
	fi
}


############################################################################################################################################################
## Run a single test suite pointing to a postman collection
## This method allows to pass ';' seperated postman environmental variables.
## Usage run_test <collection_name> <environment_file_location> <environment_Variables> <test_result_folder>
############################################################################################################################################################
run_test() {
 test_collection=$1
 environment_file=$2
 env_vars=$3
 result_folder=$4
 

 
 newman_environment=
 
 if [ ! -z "$env_vars" ]
 then
    split $env_vars ";"
	echo $env_vars_array
	for i in "${env_vars_array[@]}"  
	do  
		newman_environment="$newman_environment --env-var $i "
	done  
 fi
 
 
 echo "Running postman tests"
 echo "Environment:$environment_file"
 
 if [ -z "$newman_environment" ] 
 then
  newman run $test_collection  --reporters cli,junit,html --reporter-junit-export $result_folder/$RANDOM.xml -e $environment_file --reporter-html-export $result_folder/index.html
 else 
  newman run $test_collection  --reporters cli,junit,html --reporter-junit-export $result_folder/$RANDOM.xml -e $environment_file $newman_environment --reporter-html-export $result_folder/index.html
 fi
}

############################################################################################################################################################
## Run the entire postman test suite pointing to an API Gateway server.
## 
## When 'all' is passed all tests under tests/test-suites are run
## Usage run_test_suite <test_suite> <environment_file_location> <api_gateway_server> <test_result_folder>
############################################################################################################################################################

run_test_suite() {

    test_suite=$1
	environment_file_location=$2
	apigateway_server_url=$3
	result_folder=$4
	if [ -d "$result_folder" ] 
	then
		rm -R $result_folder
	fi
 
   mkdir $result_folder
	
	CURR_DIR="../"
	API_DIR=$CURR_DIR/tests/test-suites/

	
	echo "Running tests for API gateway"
	if [ $test_suite = "all" ] 
	then 
	for file in $API_DIR/*; do
		run_test $file $2 "httpInvokeUrl=$apigateway_server_url" $4
	done
	exit
	fi

	run_test $test_suite $2  "httpInvokeUrl=$apigateway_server_url" $4
}

############################################################################################################################################################
## Promotes an API Project using the API Gateway Promotion management API.
## Usage promote_api <api_project> <environment_file_location> <environment_Variables>
############################################################################################################################################################
promote_api() {

   CURR_DIR="../"
   PROMOTION_MANAGEMENT=$CURR_DIR/utilities/promotion/PromotionManagement.json
   PROMOTION_MANAGEMENT_PAYLOAD=$CURR_DIR/apis/$1/promotion_payload.json
   env_vars=$3
   
   newman_environment=
 
	 if [ ! -z "$env_vars" ]
	 then
		split $env_vars ";"
		echo $env_vars_array
		for i in "${env_vars_array[@]}"  
		do  
			newman_environment="$newman_environment --env-var $i "
		done  
	 fi
   
   newman run $PROMOTION_MANAGEMENT  -g $2 -e $PROMOTION_MANAGEMENT_PAYLOAD $newman_environment
}


##############################################################################
## Utility method to split a input with an delimter
## Usage split input delimiter
## Output array of the string that is split.
##############################################################################
split() {
  input=$1
  delimiter=$2
  string=$input$delimiter

#Split the text based on the delimiter
env_vars_array=()
while [[ $string ]]; do
  env_vars_array+=( "${string%%"$delimiter"*}" )
  string=${string#*"$delimiter"}
done
}
