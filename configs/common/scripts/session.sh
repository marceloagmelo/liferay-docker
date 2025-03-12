#!/bin/bash

timeout=720
echo "updating web.xml"
sed -i -e "s/<session-timeout>.*<\/session-timeout>/<session-timeout>$timeout<\/session-timeout>/" $LIFERAY_HOME/tomcat/webapps/ROOT/WEB-INF/web.xml