#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
cd "$( dirname "$SOURCE" )"

bash -x -e ./all.sh
for dir in ./*/;do
    docker push "libfuzzer/$( basename $dir)"
done
