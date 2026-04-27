#!/bin/bash

while :;
do
	java -server -Dfile.encoding=UTF-8 -Xmx64m \
		--add-opens java.base/java.lang=ALL-UNNAMED \
		--add-opens java.base/java.lang.reflect=ALL-UNNAMED \
		--add-opens java.base/java.io=ALL-UNNAMED \
		--add-opens java.base/java.util=ALL-UNNAMED \
		--add-opens java.base/java.util.concurrent=ALL-UNNAMED \
		--add-opens java.base/java.net=ALL-UNNAMED \
		--add-opens java.base/sun.nio.ch=ALL-UNNAMED \
		--add-opens java.base/sun.security.ssl=ALL-UNNAMED \
		--add-opens java.base/java.lang.invoke=ALL-UNNAMED \
		-cp config:./lib/* l2s.authserver.AuthServer > log/stdout.log 2>&1

	[ $? -ne 2 ] && break
	sleep 10;
done
