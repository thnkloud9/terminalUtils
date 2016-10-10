
wget http://www.iterm2.com/downloads.html

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# install patched font
# after this you will need to double click the otf font file to install in OSX
# then update iTerm2 profile text and color preferences
wget https://github.com/powerline/fonts/raw/master/Meslo/Meslo%20LG%20M%20DZ%20Regular%20for%20Powerline.otf

# copy zsh prefs
cp ./.zshrc ~/.zshrc
