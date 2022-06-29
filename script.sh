# adding variables
echo "##### Adding variables"
PORT=3001
ROOT_FOLDER=~/testingReact/
REPO_FOLDER=./my-react-app/
RUNNING_FOLDER=./running/
RUNNING_APP_NAME=myReactApp
TEMP_FOLDER=./tmp/
OLD_FOLDER=./old/

# switching to repo folder
echo "##### Switching to repo folder"
cd ${ROOT_FOLDER}
cd ${REPO_FOLDER}

# removing package-lock.json
echo "##### Removing package-lock.json"
rm package-lock.json

# installing dependencies
echo "##### Installing dependencies"
npm install
if [ $? -eq 0 ]; then # if dependencies installation went successfull
    echo "##### Dependencies installation went successfull"
    # running build process
    echo "##### Running build process"
    npm run build
    if [ $? -eq 0 ]; then
        # if buld process went successfull
        echo "##### Build process went successfull"
        # switching to versions containing folder
        echo "##### Switching to versions containing folder"
        cd ../
        # creating temporary folder
        echo "##### Creating temporary folder"
        mkdir $TEMP_FOLDER
        # copying build files into temporary folder
        echo "##### Copying build files into temporary folder"
        cp -r $REPO_FOLDER. $TEMP_FOLDER
        # cp nuxt.config.js $TEMP_FOLDER/nuxt.config.js
        # stopping running app
        echo "##### Stopping running app"
        pm2 stop $RUNNING_APP_NAME
        # changing running folder's name into old
        echo "##### Changing running folder's name into old"
        mv $RUNNING_FOLDER $OLD_FOLDER
        # changing temporary folder's name into running
        echo "##### Changing temporary folder's name into running"
        mv $TEMP_FOLDER $RUNNING_FOLDER
        # switching to running folder
        echo "##### Switching to running folder"
        cd $RUNNING_FOLDER
        # checking if the running app's process exists
        echo "##### Checking if the running app's process exists"
        pm2 show $RUNNING_APP_NAME
        if [ $? -eq 0 ]; then # running app's process exists
            # running app's process exists, launching the app
            echo "##### Running app's process exists, launching the app"
            pm2 start $RUNNING_APP_NAME
        else
            # running app's process doesn't exist, creating a process for it and then launching it
            echo "##### Running app's process doesn't exist, creating a process for it and then launching it"
            pm2 start "serve -s build -l $PORT" --name $RUNNING_APP_NAME
        fi
        echo "##### Enjoy the app!"
        # switching to versions containing folder
        echo "##### Switching to versions containing folder"
        cd ../
        # removing old folder
        echo "##### Removing old folder"
        rm -rf $OLD_FOLDER
    else
        echo "##### There was an error during build phase"
    fi
else
    echo "##### There was an error during dependencies installation phase"
fi
