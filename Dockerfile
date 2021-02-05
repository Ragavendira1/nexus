FROM sonatype/nexus3
USER root

#RUN apk add --no-cache curl tar bash procps
RUN  yum -y install cronie


# Downloading and installing Maven
# 1- Define a constant with the version of maven you want to install
ARG MAVEN_VERSION=3.6.1         

# 2- Define a constant with the working directory
ARG USER_HOME_DIR="/root"

# 3- Define the SHA key to validate the maven download
ARG SHA=b4880fb7a3d81edd190a029440cdf17f308621af68475a4fe976296e71ff4a4b546dd6d8a58aaafba334d309cc11e638c52808a4b0e818fc0fd544226d952544

# 4- Define the URL where maven can be downloaded from
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

# 5- Create the directories, download maven, validate the download, install it, remove downloaded file and set links
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && echo "Downlaoding maven" \
  && curl -fsSL -o /tmp/apache-maven.tar.gz http://apachemirror.wuchna.com/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz \
  \
  && echo "Checking download hash" \
#  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  \
  && echo "Unziping maven" \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# 6- Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

WORKDIR /usr/share/script
COPY apache-groovy-binary-3.0.4 /usr/share/apache-groovy-binary-3.0.4
ENV PATH /usr/share/apache-groovy-binary-3.0.4/groovy-3.0.4/bin/:$PATH

COPY nexus.properties /nexus-data/etc/nexus.properties
COPY addRole.groovy /usr/share/script/addRole.groovy
COPY addUpdateScript.groovy /usr/share/script/addUpdateScript.groovy
COPY core.groovy /usr/share/script/core.groovy
COPY createRepositoryMaven.groovy /usr/share/script/createRepositoryMaven.groovy
COPY createRepositoryDocker.groovy /usr/share/script/createRepositoryDocker.groovy
COPY dockerRepositories.groovy /usr/share/script/dockerRepositories.groovy
COPY grapeConfig.xml /usr/share/script/grapeConfig.xml
COPY npmAndBowerRepositories.groovy /usr/share/script/npmAndBowerRepositories.groovy
COPY provision.sh /usr/share/script/provision.sh
COPY rawRepositories.groovy /usr/share/script/rawRepositories.groovy
COPY security.groovy /usr/share/script/security.groovy

#RUN /usr/share/script/provision.sh

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Setup cron job
#RUN (crontab -l ; echo "* * * * * echo "Hello world" >> /var/log/cron.log") | crontab
RUN echo "*/5 * * * * sh /usr/share/script/provision.sh >> /var/log/cron.log 2>&1" | crontab

# Run the command on container startup
#CMD tail -f /var/log/cron.log