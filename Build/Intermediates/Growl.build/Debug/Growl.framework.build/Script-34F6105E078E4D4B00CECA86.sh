#!/bin/sh
find "$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME" '(' -name '.svn' -or -name '.DS_Store' ')' -prune -print0 | xargs -0 rm -rf

