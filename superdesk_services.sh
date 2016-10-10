#!/bin/bash

if [ $1 = 'start' ]; then
    # mongo
    brew services start mongodb
    #launchctl load ~/Library/LaunchAgents/org.mongodb.mongod.plist
    # redis
    brew services start redis 
    #launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
    # elasticsearch
    brew services start elasticsearch 
    #launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist
fi

if [ $1 = 'stop' ]; then
    # mongo
    brew services stop mongodb
    #launchctl unload ~/Library/LaunchAgents/org.mongodb.mongod.plist
    # redis
    brew services stop redis 
    #launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
    # elasticsearch
    brew services stop elasticsearch 
    #launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist
fi
