#!/bin/bash
#entrypoint pre-initialization
source /environment

export TMPDIR=/tmp
export JOBLIB_TEMP_FOLDER=$TMPDIR

#run the user command
exec "$@"
