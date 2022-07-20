# ----------------------------------------------------------------------------------------------------------------------------------------------------
# starting the magic
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "The magic is about to start!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# adding variables
echo "Adding variables."

# foldering variables
ROOT_FOLDER=~/testingReact/
REPO_FOLDER=./my-react-app/
RUNNING_FOLDER=./running/
TEMP_FOLDER=./tmp/
OLD_FOLDER=./old/

# pipeline variables
PIPELINE_NAME=my-react-app-pipeline

# app variables
RUNNING_APP_PORT=3051
RUNNING_APP_COMMAND="serve -s build -l $RUNNING_APP_PORT"
RUNNING_APP_NAME=myReactApp

# discord bot variables
DISCORD_BOT_FOLDER=~/testingReact/discord-bot/
DISCORD_BOT_ENV_FILE_PATH=$DISCORD_BOT_FOLDER".env"
DISCORD_BOT_SCRIPT=$DISCORD_BOT_FOLDER"src/bot.js"
DISCORD_BOT_MESSAGES_IDS=$DISCORD_BOT_FOLDER"messages-ids.txt"

# messaging variables
MESSAGE=""
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# switching to the root folder
echo "Switching to the root folder."
cd $ROOT_FOLDER
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# creating the temporary folder
echo "Creating the temporary folder."
mkdir $TEMP_FOLDER
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# switching to the temporary folder
echo "Switching to the temporary folder"
cd $TEMP_FOLDER
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# saving pipeline logs to pipeline-info.json file
echo "Saving pipeline logs to pipeline-info.json file."
aws codepipeline get-pipeline-state --name $PIPELINE_NAME >pipeline-info.json
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# extracting commit ID and commit message from pipeline-info.json file
echo "Extracting commit ID and message from pipeline-info.json file."
COMMIT_ID=$(jq -r '.stageStates[0] | .actionStates[0] | .latestExecution | .externalExecutionId' pipeline-info.json)
COMMIT_MESSAGE=$(jq -r '.stageStates[0] | .actionStates[0] | .latestExecution | .summary' pipeline-info.json | jq -r '.CommitMessage')
echo "Commit ID: $COMMIT_ID"
echo "Commit message: $COMMIT_MESSAGE"
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# repo is successfully pulled
MESSAGE="Deployment is successfully pulled \nn Commit ID: $COMMIT_ID \n Commit message: $COMMIT_MESSAGE"
echo $MESSAGE

# sending the message to Discord
node $DISCORD_BOT_SCRIPT $DISCORD_BOT_ENV_FILE_PATH SEND_MESSAGE $MESSAGE
if [ $? -eq 0 ]; then
    echo "Discord Bot's sent the message."
else
    echo "There was an error with the bot."
fi
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# switching to the root folder
echo "Switching to the root folder."
cd $ROOT_FOLDER
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# removing old build's folder
echo "Removing old build's folder."
rm -rf $OLD_FOLDER
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# copying the files from the repo folder into the temporary folder
cp -r $REPO_FOLDER. $TEMP_FOLDER
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# switching to the temporary folder
echo "Switching to the temporary folder"
cd $TEMP_FOLDER
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# installing dependencies
echo "Installing dependencies."
npm install

# if dependencies installation went successful
if [ $? -eq 0 ]; then
    echo "Dependencies installation went successful."

    # ----------------------------------------------------------------------------------------------------------------------------------------------------
    # running build process
    MESSAGE="Deployment is building..."
    echo $MESSAGE

    # sending the message to Discord
    node $DISCORD_BOT_SCRIPT $DISCORD_BOT_ENV_FILE_PATH SEND_MESSAGE $MESSAGE
    if [ $? -eq 0 ]; then
        echo "Discord Bot's sent the message."
    else
        echo "There was an error with the bot."
    fi

    npm run build
    # if buld process went successful
    if [ $? -eq 0 ]; then
        MESSAGE="Build process went successful!"
        echo $MESSAGE

        # sending the message to Discord
        node $DISCORD_BOT_SCRIPT $DISCORD_BOT_ENV_FILE_PATH SEND_MESSAGE $MESSAGE
        if [ $? -eq 0 ]; then
            echo "Discord Bot's sent the message."
        else
            echo "There was an error with the bot."
        fi

        # switching to the root folder
        echo "Switching to the root folder."
        cd $ROOT_FOLDER

        # stopping running app
        echo "Stopping running app."
        pm2 stop $RUNNING_APP_NAME

        # changing running folder's name into old
        echo "Changing running folder's name into old."
        mv $RUNNING_FOLDER $OLD_FOLDER

        # changing temporary folder's name into running
        echo "Changing temporary folder's name into running."
        mv $TEMP_FOLDER $RUNNING_FOLDER

        # switching to running folder
        echo "Switching to running folder."
        cd $RUNNING_FOLDER

        # checking if the running app's process exists
        echo "Checking if the running app's process exists."
        pm2 show $RUNNING_APP_NAME
        if [ $? -eq 0 ]; then # running app's process exists
            # running app's process exists, launching the app
            echo "Running app's process exists, launching the app."
            pm2 start $RUNNING_APP_NAME
        else
            # running app's process doesn't exist, creating a process for it
            echo "Running app's process doesn't exist, creating a process for it and then launching it."
            # launching the process
            pm2 start $RUNNING_APP_COMMAND --name $RUNNING_APP_NAME
        fi

        # deployment is successfully deployed
        MESSAGE="Deployment is successfully deployed \nn Commit ID: $COMMIT_ID \n Commit message: $COMMIT_MESSAGE"
        echo $MESSAGE

        # sending the message to Discord
        node $DISCORD_BOT_SCRIPT $DISCORD_BOT_ENV_FILE_PATH SEND_MESSAGE $MESSAGE
        if [ $? -eq 0 ]; then
            echo "Discord Bot's sent the message."

            # removing previous messages from Discord
            node $DISCORD_BOT_SCRIPT $DISCORD_BOT_ENV_FILE_PATH REMOVE_MESSAGES
            if [ $? -eq 0 ]; then
                echo "Discord Bot's removed previous messages."
            else
                echo "There was an error with the bot."
            fi
        else
            echo "There was an error with the bot."

            # removing messages-ids.txt file
            rm $DISCORD_BOT_MESSAGES_IDS
        fi

    # if there was an error during build phase
    else
        MESSAGE="There was an error during build phase."
        echo $MESSAGE

        # sending the message to Discord
        node $DISCORD_BOT_SCRIPT $DISCORD_BOT_ENV_FILE_PATH SEND_MESSAGE $MESSAGE
        if [ $? -eq 0 ]; then
            echo "Discord Bot's sent the message."
        else
            echo "There was an error with the bot."
        fi

        # removing messages-ids.txt file
        rm $DISCORD_BOT_MESSAGES_IDS

        # switching to the root folder
        echo "Switching to the root folder."
        cd $ROOT_FOLDER

        # removing the temporary folder
        rm -rf $TEMP_FOLDER
    fi
    # ----------------------------------------------------------------------------------------------------------------------------------------------------

# if dependencies installation went unsuccessfull
else
    MESSAGE="There was an error during dependencies installation phase."
    echo $MESSAGE

    # sending the message to Discord
    node $DISCORD_BOT_SCRIPT $DISCORD_BOT_ENV_FILE_PATH SEND_MESSAGE $MESSAGE
    if [ $? -eq 0 ]; then
        echo "Discord Bot's sent the message."
    else
        echo "There was an error with the bot."
    fi

    # removing messages-ids.txt file
    rm $DISCORD_BOT_MESSAGES_IDS

    # switching to the root folder
    echo "Switching to the root folder."
    cd $ROOT_FOLDER

    # removing the temporary folder
    rm -rf $TEMP_FOLDER
fi
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# sending a separating line to Discord
echo "Sending a separating line to Discord"

MESSAGE="-------------------------------------------"
echo $MESSAGE

# sending the message to Discord
node $DISCORD_BOT_SCRIPT $DISCORD_BOT_ENV_FILE_PATH SEND_MESSAGE $MESSAGE
if [ $? -eq 0 ]; then
    echo "Discord Bot's sent the message."

    # removing messages-ids.txt file
    rm $DISCORD_BOT_MESSAGES_IDS
else
    echo "There was an error with the bot."
fi
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# ending the magic
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "The magic is over, but not forever!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# ----------------------------------------------------------------------------------------------------------------------------------------------------
