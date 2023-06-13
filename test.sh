#!/usr/bin/env sh

# no color
if [ -z "$NOCOLOR" ]; then
	RED='\033[0;31m'
	GREEN='\033[0;32m'
    NC='\033[0m'
else
    RED=""
    GREEN=""
    NC=""
fi

test () {
    OUTPUT=$(eval "$2" 2>&1)
    EXPECT="$3"
    if [ "$OUTPUT" = "$EXPECT" ]; then
        printf "TEST: %-20.20s ${GREEN}PASSED${NC}\n" "$1"
    else
        printf "TEST: %-20.20s ${RED}FAILED${NC}\n" "$1"
        echo "EXPECTED:"
	echo "$EXPECT"
        echo "GOT:"
	echo "$OUTPUT"
    fi
}

tmp_file () {
    FILE=$(mktemp /tmp/tagger-test-file-XXXXXX)
    BASENAME=$(basename "$FILE")
}    

FOLDER=$(mktemp -d /tmp/tagger-test-XXXXXX)
LS_FOLDER="&& cd $FOLDER && find ."

test "init" "./tagger $FOLDER init $LS_FOLDER" \
".
./.base"

test "init: already exist" "./tagger $FOLDER init" \
"folder is already contain tagger: $FOLDER"

tmp_file
test "add file" "./tagger $FOLDER add $FILE $LS_FOLDER" \
".
./.base
./.base/$BASENAME"
rm -f "$FILE"

test "tag file" "./tagger $FOLDER tag $BASENAME a $LS_FOLDER" \
".
./.base
./.base/$BASENAME
./a
./a/$BASENAME"

test "untag file" "./tagger $FOLDER untag $BASENAME a $LS_FOLDER" \
".
./.base
./.base/$BASENAME
./a"

test "ls files" "./tagger $FOLDER ls" "$BASENAME"

test "path file" "./tagger $FOLDER path $BASENAME" "$FOLDER/.base/$BASENAME"

rm -rf "$FOLDER"
