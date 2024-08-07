#!/bin/sh
set -e

programname=$0
function usage {
    echo ""
    echo "Launch local server providing the chatbot service."
    echo ""
    echo "usage: $programname --no_backend_build"
    echo ""
    echo "  --no_backend_build   If specified, python venv will not be (re)created"
    echo ""
    echo "  --no_frontend_build   If specified, frontend will not be built anew"
    echo ""
}

function die {
    printf "Script failed: %s\n\n" "$1"
    exit 1
}

no_backend_build="false"
no_frontend_build="false"
while [ $# -gt 0 ]; do
    if [[ $1 == "--help" ]]; then
        usage
        exit 0
    elif [[ $1 == "--"* ]]; then
        v="${1/--/}"
        if [[ -z $2 || $2 == "-"* ]]; then
            declare "$v"="true"
        else
            declare "$v"="$2"
            shift
        fi
    fi
    shift
done


# Build frontend
if [[ $no_frontend_build == "true" ]]; then
    echo ""
    echo "Skipping building frontend, assume it already exists and is correct."
else
    echo ""
    echo "Restoring frontend npm packages"
    echo ""
    cd frontend
    npm install
    if [ $? -ne 0 ]; then
        echo "Failed to restore frontend npm packages"
        exit $?
    fi

    echo ""
    echo "Building frontend"
    echo ""
    npm run build
    if [ $? -ne 0 ]; then
        echo "Failed to build frontend"
        exit $?
    fi
    cd ..
fi


# Build backend
echo ""
. ./scripts/loadenv.sh
if [[ $no_backend_build == "true" ]]; then
    echo ""
    echo "Skipping building python env, assume it already exists."
else
    . ./scripts/setupvenv.sh
fi


# Launch the server
echo ""
echo "Starting backend"
echo ""
./.venv/bin/python -m quart run --port=50505 --host=127.0.0.1 --reload
if [ $? -ne 0 ]; then
    echo "Failed to start backend"
    exit $?
fi
