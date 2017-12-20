#! /bin/sh
set -eo pipefail

[ "$DEBUG" ] && set -x

# set current working directory to the directory of the script
cd "$(dirname "$0")"

dockerImage=${1:-app:latest}

echo "Testing $dockerImage..."

if ! docker inspect "$dockerImage" &> /dev/null; then
    echo $'\timage does not exist!'
    false
fi

# running tests
docker run -v $PWD:/src $dockerImage node -v &>/dev/null || (echo "node failed" && exit 1)
docker run -v $PWD:/src $dockerImage java -version &>/dev/null || (echo "java failed" && exit 1)
docker run -v $PWD:/src $dockerImage dot -V &>/dev/null || (echo "dot failed" && exit 1)
docker run -v $PWD:/src $dockerImage aws --version &>/dev/null || (echo "aws failed" && exit 1)

docker run -v $PWD:/src $dockerImage textlint -v &>/dev/null || (echo "textlint failed" && exit 1)
docker run -v $PWD:/src $dockerImage redpen -v &>/dev/null || (echo "redpen failed" && exit 1)

docker run -v $PWD:/src $dockerImage gitbook &>/dev/null || (echo "gitbook failed" && exit 1)
docker run -v $PWD:/src $dockerImage ebook-convert --version &>/dev/null || (echo "ebook-convert failed" && exit 1)

