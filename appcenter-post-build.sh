if [ -z "${APPCENTER_ANDROID_VARIANT}" ]
  then
    echo "done build not distributed because of iOS"
  else
    appcenter distribute release \
    --group "$ENV_DISTRIBUTE_GROUP" \
    -f $APPCENTER_OUTPUT_DIRECTORY/app-debug.apk \
    --app $ENV_APP_NAME \
    --token $ENV_APPCENTER_BUILD_TOKEN \
    --release-notes "$ENV_DISTRIBUTE_MESSAGE"
fi