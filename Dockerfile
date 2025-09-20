FROM tomcat:9-jdk11
COPY target/ABCtechnologies-1.0.war /usr/local/tomcat/webapps/
