#!/bin/bash
#Sample Usage: publishFeatures.sh projectName ATUH_TOKEN
PROJECT_NAME=$1
PROJECT_CONFIG=$2
ATUH_TOKEN=$3
PROJECT_ARTIFACTS="${PROJECT_NAME}_artifacts.txt"
function main() {
download_artifacts
build
}
function download_artifacts() {
echo "${PROJECT_NAME}"
echo "${PROJECT_ARTIFACTS}"
URL="https://circleci.com/api/v1.1/project/github/epsilonlabs/${PROJECT_NAME}/latest/artifacts"
QUERY="?circle-token=${ATUH_TOKEN}"
curl $URL $QUERY | grep -o 'https://[^"]*' > $PROJECT_ARTIFACTS
}

function build() {
<$PROJECT_ARTIFACTS xargs -P4 -I % wget -x -nH --cut-dirs=1 % -P ./epsilonlabs-artifacts/$PROJECT_NAME/
	java -jar ./eclipse/plugins/org.eclipse.equinox.launcher_*.jar \
    	-application org.eclipse.equinox.p2.publisher.FeaturesAndBundlesPublisher \
        -metadataRepository file:$(pwd)/repository/$PROJECT_NAME \
        -artifactRepository file:$(pwd)/repository/$PROJECT_NAME \
        -source ./epsilonlabs-artifacts/$PROJECT_NAME/ \
        -configs $PROJECT_CONFIG \
        -compress \
        -publishArtifacts
}

main "$@"