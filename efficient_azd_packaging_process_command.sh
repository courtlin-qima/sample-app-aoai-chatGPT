#/bin/bash
set -e
# set -o xtrace # Used to display the command as they are being run in the bash script.

# The goal of this script is to make it so that the command to run, notably those
# involving to package the project, are run in a context where only the files
# needed for packaging are present.

# Make sure that the command being provided is correct
POSSIBLE_COMMANDS="package deploy" # Dont use commands related to provisioning, since those may result in the .env file being written, except here it would be written in a folder which would be deleted afterward

if [ -z "$1" ];
then
    echo "No command have been provided. Possible command value(s) are one of: $POSSIBLE_COMMANDS.";
    exit 0;
fi

command=$1

command_is_known="false";
for possible_command in $POSSIBLE_COMMANDS
do
    if [ "$possible_command" == "$command" ];
    then
        command_is_known="true";
    fi
done

if [ "$command_is_known" == "false" ];
then
    echo "Incorrect command '$command' to run with this script. Possible command value(s) are one of: $POSSIBLE_COMMANDS.";
    exit 0;
fi

# Then, run the script
TMP_FOLDER_NAME="tmp_deploy_project";

echo "Copying needed info into tmp folder '$TMP_FOLDER_NAME'..."
rm -rf $TMP_FOLDER_NAME;
mkdir $TMP_FOLDER_NAME;
cp -r frontend backend example_data infra infrastructure scripts tests *.py \
    efficient_azure.yaml *.md LICENSE start.* WebApp.* .azure .devcontainer .github \
    requirements.txt requirements-dev.txt \
    ./$TMP_FOLDER_NAME/;
cd $TMP_FOLDER_NAME;
mv efficient_azure.yaml azure.yaml;

echo "Building frontend data...";
cd ./frontend; npm install; npm run build;
cd ../;
rm -r frontend/node_modules;

echo "Performing the azd command '$command'",
azd $command;
cd ../;

echo "Cleaning up the tmp folder..."
rm -rf $TMP_FOLDER_NAME;
