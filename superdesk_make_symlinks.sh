#
# links dependencies in superdesk main repository checkout to local dev checkouts
#

# client
SITESDIR=/Users/marklewis/Sites
CLIENTDIR=$SITESDIR/superdesk/client
CLIENTCOREDIR=$SITESDIR/superdesk-client-core
SERVERDIR=$SITESDIR/superdesk/server
SERVERCOREDIR=$SITESDIR/superdesk-core
SERVERVENVDIR=$SITESDIR/superdesk/server/env

#
# Client link
################
if [ -d "$CLIENTCOREDIR" ]; then
    # check if the sym link already exists first
    if [ -L $CLIENTDIR/node_modules/supdesk-core ]; then
        echo "Symlink $CLIENTDIR/node_modules/supdesk-core already exists!"
    else
        if [ ! -d "$CLIENTDIR/node_modules" ]; then
            echo "Looks like npm install was not run, running now"
            (cd $CLIENTDIR; npm install)
        else
            echo "Found $CLIENTDIR/node_modules"
        fi

        rm -rf $CLIENTDIR/node_modules/supdesk-core
        ln -s $CLIENTCOREDIR $CLIENTDIR/node_modules/supdesk-core
    fi
else
    # no clone of superdesk/superdesk-client-core exists
    echo "You must first fork and clone the repo: https://github.com/superdesk/superdesk-client-core into your $SITESDIR folder"
fi

#
# Server link
################
if [ -d "$SERVERCOREDIR" ]; then
    # check if the sym link already exists first
    if [ -L $SERVERDIR/env/src/superdesk-core ]; then
        echo "Symlink $SERVERDIR/env/src/superdesk-core already exists!"
    else
        # check if the python virtual env exists
        if [ ! -d "$SERVERVENVDIR" ]; then
            # create virtual env
            virtualenv -p python3 $SERVERVENVDIR
            # notify user here that he should start the new venv, then run pip install -r requirements.txt
            # then re-run this script to finish the core symlink
            echo "Created $SERVERVENVDIR using python3.  You must now start the venv and run 'pip install -r requirements.txt'.  Then you should re-run this script to finish supdesk-core sym link"
        else
            echo "Found $SERVERVENVDIR"
        fi

        if [ ! -d "$SERVERVENVDIR/src" ]; then
            # create virtual env src
            mkdir $SERVERVENVDIR/src
        else
            # remove pre-installed superdesk site-packages
            rm -rf $SERVERVENVDIR/lib/python3.4/site-packages/apps
            rm -rf $SERVERVENVDIR/lib/python3.4/site-packages/superdesk
            rm -rf $SERVERVENVDIR/lib/python3.4/site-packages/tests
        fi 
        ln -s $SERVERCOREDIR $SERVERDIR/env/src/superdesk-core
    fi
else
    # no clone of superdesk/superdesk-core exists
    echo "You must first fork and clone the repo: https://github.com/superdesk/superdesk-core into your $SITESDIR folder"
fi
