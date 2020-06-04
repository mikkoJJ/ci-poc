#!/bin/sh
echo "JAVA_OPTS: $JAVA_OPTS"
exec java -cp app -Dnoverify -Djava.security.egd=file:/dev/./urandom $JAVA_OPTS org.springframework.boot.loader.JarLauncher
