#!/bin/bash

# File managers: Double Commander, Midnight Commander
echo -e "${GREEN}===========================Double Commander=================================${NC}"

apt-get install -y -qq doublecmd-qt 2>&1 | tee -a "$LOG_FILE"

# create config file befor first run. double commander will add other default settings to this file
DOUBLECMD_CFG_DIR="$CONFIG_DIR/doublecmd"
mkdir $DOUBLECMD_CFG_DIR
cp $(pwd)/doublecmd.xml "$DOUBLECMD_CFG_DIR/doublecmd.xml"
chown $TARGET_USER:$TARGET_USER $DOUBLECMD_CFG_DIR
chown $TARGET_USER:$TARGET_USER "$DOUBLECMD_CFG_DIR/doublecmd.xml"
chmod 764 $DOUBLECMD_CFG_DIR
chmod 664 "$DOUBLECMD_CFG_DIR/doublecmd.xml"

# replace some property in xml filse
#REPL="s|<Name>.*</Name>|<Name>JetBrains Mono</Name>|"
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<Main>/,/<\/Main>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<Editor>/,/<\/Editor>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<Viewer>/,/<\/Viewer>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<ViewerBook>/,/<\/ViewerBook>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<Log>/,/<\/Log>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<Console>/,/<\/Console>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<PathEdit>/,/<\/PathEdit>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<FunctionButtons>/,/<\/FunctionButtons>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<SearchResults>/,/<\/SearchResults>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<TreeViewMenu>/,/<\/TreeViewMenu>/ $REPL }" $CFG_DOUBLECMD
#sed -i "/<Fonts>/,/<\/Fonts>/ { /<StatusBar>/,/<\/StatusBar>/ $REPL }" $CFG_DOUBLECMD

echo -e "${GREEN}==========================Midnight Commander================================${NC}"

apt-get install -y -qq mc 2>&1 | tee -a "$LOG_FILE"
