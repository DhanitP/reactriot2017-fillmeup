cat <<script > cirun.sh
#!/bin/bash -v
set -e
export HOME=/root
mkdir -p /root/service/tmp
HOME=/root npm install --no-optional
npm run test
script

#This script gets run inside the containers. We need to capture CI test changes inside this script.
chmod 755 cirun.sh

RUBY_VERSION=2.4.2

#If we don't have cloudfactory/ci:cfclient-FUTURE-RUBY-VERSION, we build it here and push it. Self-sustaining
docker pull cloudfactory/ci:cfclient-${RUBY_VERSION} || ( sed -i "s/RUBY_VERSION/$RUBY_VERSION/g;" .docker/ci/Dockerfile.ci &&  docker build \
-t cloudfactory/ci:cfclient-${RUBY_VERSION} \
-f .docker/ci/Dockerfile.ci .docker/ci \
&& docker push cloudfactory/ci:cfclient-${RUBY_VERSION})


#Dockerfile for temporary image derived from standalone cloudfactory/ci:cfclient-$RUBY_VERSION
cat <<startdockerfile > Dockerfile.jenkins
FROM cloudfactory/ci:cfclient-${RUBY_VERSION}
MAINTAINER DevOps <devops@cloudfactory.com>
ADD . /root/service
startdockerfile


#Build gitignore anology for docker - aptly named .dockerignore
#We don't need git inside docker containers/images
cat <<startdockerignore > .dockerignore
.git
.git/*
public/*
startdockerignore


#Docker has problem parsing uppercase :( !!!
# Having pr- suffix would allow us to do some dumb logic cleanup in CI server down the road
# ghprbActualCommit is commit SHA1 as handed over by GitHub Pull Request builder plugin
#BRANCH is handed over by Jenkins as the PR branch which is to be merged into stable master
DOCKER_TAG=$(echo pr-${BRANCH}${ghprbActualCommit}${BUILD_NUMBER} | tr A-Z a-z)

#Build the docker image with computed tag
docker build -f Dockerfile.jenkins -t $DOCKER_TAG .

#Now we run container with cirun.sh created earlier with some bind mounts such that we dont'
#have to download same thing again and again. Helps bandwidth and CI speed.
docker run -a stdout \
-v /var/lib/jenkins/node_modules:/root/service/node_modules \
-v /var/lib/jenkins/node:/root/.node \
--rm -t $DOCKER_TAG \
/sbin/my_init --quiet -- ./cirun.sh
