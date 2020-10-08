#!/bin/sh
set -ex

PORT=80
ELEMENT_VERSION=LATEST

function usage()
{
    echo "Runs a riot-web server"
    echo ""
    echo "/start.sh"
    echo "\t-h --help"
    echo "\t--port=$PORT"
    echo "\t--riot-version=$ELEMENT_VERSION"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --port)
            PORT=$VALUE
            ;;
        --riot-version)
            ELEMENT_VERSION=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [ "$ELEMENT_VERSION" = "LATEST" ]
then
    ELEMENT_VERSION=$(curl --silent "https://api.github.com/repos/vector-im/element-web/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi

echo "Downloading element-web $ELEMENT_VERSION"
cp /www/config.json /tmp/config.json
cd /tmp
# https://github.com/vector-im/element-web/issues/15423
wget "https://github.com/vector-im/element-web/releases/download/$ELEMENT_VERSION/riot-$ELEMENT_VERSION.tar.gz" -O element.tar.gz

echo "Unpacking element-web"
rm -rf /www
mkdir -p /www
tar -zxvf element.tar.gz --strip-components=1 -C /www
cp /tmp/config.json /www/config.json

echo "Starting nginx on port $PORT"
sed -i "s/NOMAD_HTTP_PORT/$PORT/g" /etc/nginx/nginx.conf
nginx
