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
        # creating tmp folder
        echo "##### Creating tmp folder"
        mkdir tmp
        # switching to the repo folder
        echo "##### Switching to the repo folder"
        cd ./my-react-app/
        # copying build files into tmp folder
        # cp -r build package.json package-lock.json README.md ../tmp
        echo "##### Copying build files into tmp folder"
        cp -r build ../tmp
        # switching to versions containing folder
        echo "##### Switching to versions containing folder"
        cd ../
        # killing running app
        echo "##### Killing the running app"
        fuser -k 3000/tcp
        # changing running folder's name into dummy
        echo "##### Changing running folder's name into dummy"
        mv ./running/ ./dummy/
        # changing tmp folder's name into running
        echo "##### Changing tmp folder's name into running"
        mv ./tmp/ ./running/
        # removing dummy folder
        echo "##### Removing dummy folder"
        rm -rf ./dummy/
        # switching to running folder
        echo "##### Switching to running folder"
        cd ./my-react-app/
        # running the app
        echo "##### Running the app"
        serve -s build
    else
        echo "##### There was an error during build phase"
    fi
else
    echo "##### There was an error during dependencies installation phase"
fi
