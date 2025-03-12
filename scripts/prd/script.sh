#!/bin/bash

keytool -import -alias honda.com.br -keystore /opt/jdk/jre/lib/security/cacerts -file /lcp-container/certificates/honda.com.br.pem -storepass changeit -noprompt