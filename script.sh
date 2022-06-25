# adding env variables from .env
set -a
. ./.env
set +a

printenv

# installing dependencies
echo "##### Installing dependencies"
npm install
if [ $? -eq 0 ]; then # if dependencies installation went successfull
    echo "##### Dependencies installation went successfull"
    # running build process
    echo "##### Running build process"
    npm run build
    if [ $? -eq 0 ]; then # if buld process went successfull
        echo "##### Build process went successfull"
        # switching to versions containing folder
        echo "##### Switching to versions containing folder"
        cd ../
        # creating temporary folder
        echo "##### Creating temporary folder"
        mkdir $TEMP_FOLDER
        # switching to the repo folder
        echo "##### Switching to the repo folder"
        cd $REPO_FOLDER
        # copying build files into temporary folder
        echo "##### Copying build files into temporary folder"
        # sleep 30
        cp -r build ../$TEMP_FOLDER
        # switching to versions containing folder
        echo "##### Switching to versions containing folder"
        cd ../
        # killing running app
        echo "##### Killing the running app on port $PORT"
        fuser -k $PORT/tcp
        # sleep 5
        # changing running folder's name into old
        echo "##### Changing running folder's name into old"
        mv $RUNNING_FOLDER $OLD_FOLDER
        # changing temporary folder's name into running
        echo "##### Changing temporary folder's name into running"
        mv $TEMP_FOLDER $RUNNING_FOLDER
        # switching to running folder
        echo "##### Switching to running folder"
        cd $RUNNING_FOLDER
        # running the app
        echo "##### Running the app on port $PORT"
        serve -s build -l $PORT &>filename.log &
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
