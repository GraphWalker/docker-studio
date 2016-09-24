FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
  openjdk-8-jdk \
  maven \
  git \
  nodejs \
  npm \
  sudo \
  firefox && \
  rm -rf /var/cache/apt/
  
RUN sudo ln -s "$(which nodejs)" /usr/bin/node

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
  mkdir -p /home/developer && \
  mkdir -p /etc/sudoers.d && \
  echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
  echo "developer:x:${uid}:" >> /etc/group && \
  echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
  chmod 0440 /etc/sudoers.d/developer && \
  chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer

RUN cd /home/developer && \
  git clone https://github.com/GraphWalker/graphwalker-project && \
  cd graphwalker-project/graphwalker-studio/src/main/webapp && \
  sudo npm install -g && \
  sudo npm install webpack -g && \
  webpack && \
  cd /home/developer/graphwalker-project && \
  mvn package -pl graphwalker-studio -am

RUN cd /home/developer && \
  echo "#!/bin/bash" > start.sh && \
  echo "cd /home/developer/graphwalker-project && java -jar graphwalker-studio/target/graphwalker-studio-4.0.0-SNAPSHOT.jar > studio.log 2>&1 &" >> start.sh && \
  echo "( tail -F -n0 /home/developer/graphwalker-project/studio.log & ) | grep -q 'Started Application in '" >> start.sh

RUN chmod +x /home/developer/start.sh



CMD echo "=======================================" && \
  echo "  Will start GraphWalker Studio" && \
  echo "  Please wait, will take some seconds" && \
  echo "=======================================" && \
  bash -C '/home/developer/start.sh' && \
  echo "=======================================" && \
  echo "  Studio is running!" && \
  echo "=======================================" && \
  firefox http://localhost:9090

