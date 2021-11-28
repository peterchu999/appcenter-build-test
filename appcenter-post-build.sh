# Please rename the file to `appcenter-post-build.sh`

# Function to get default distribution group and populate ENV_DISTRIBUTE_GROUP
function get_appcenter_distribute_group {
  if [ -z "${ENV_DISTRIBUTE_GROUP}" ]
    then
      ENV_DISTRIBUTE_GROUP=""
      # GROUPLIST output [ [ "Collaborators", "1" ], [ "QA Team", "1" ] ]
      GROUPLIST=`appcenter distribute groups list --app $ENV_APP_NAME --output json --token $APPCENTER_BUILD_TOKEN`


      # MAPPING GROUPLIST to JOIN seperated by ', '
      index=0
      for row in $(echo "${GROUPLIST}" | jq -r '.[] | @base64'); do
          _jq() {
          echo ${row} | base64 --decode | jq -r ${1}
          }
        for gname in $(echo $(_jq '')| jq -r '.[] | @base64'); do
          _gjq() {
            echo ${gname} | base64 --decode 
          }
          groupNAME=$(_gjq '')
          re='^[0-9]+$'
          if ! [[ $groupNAME =~ $re ]] ; then
            if [[ $index -lt 1 ]] ; then
              DISTRIBUTE_GROUP="$groupNAME"
              index=1
            else
              ENV_DISTRIBUTE_GROUP="$DISTRIBUTE_GROUP, $groupNAME"
            fi
          fi
        done
      done
      #END MAPPING
  fi
}

if [ -z "${APPCENTER_ANDROID_VARIANT}" ]
  then
    echo "done build not distributed because of iOS"
  else
    get_appcenter_distribute_group
    echo "Distribute Group :\n"
    echo $ENV_DISTRIBUTE_GROUP
    echo "\n\n END \n\n"
    appcenter distribute release \
    --group "$ENV_DISTRIBUTE_GROUP" \
    -f $APPCENTER_OUTPUT_DIRECTORY/app-debug.apk \
    --app $ENV_APP_NAME \
    --token $ENV_APPCENTER_BUILD_TOKEN \
    --release-notes "$ENV_DISTRIBUTE_MESSAGE"
fi