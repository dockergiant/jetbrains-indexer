#/bin/sh

# You can use the following environment variables at runtime
# to skip steps in this script
SKIP_GENERATE=${SKIP_GENERATE:-false}
SKIP_FORMAT=${SKIP_FORMAT:-false}
SKIP_CONFIG_FILE=${SKIP_CONFIG_FILE:-false}

echo_format() {
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

#adding /var/project to safe directory of git
if [ -d "${IDEA_PROJECT_DIR}/.git" ]; then
  git config --global --add safe.directory ${IDEA_PROJECT_DIR}
fi

# Generate indexes (dump-shared-index)
if [ "$SKIP_GENERATE" = "false" ]; then
    echo_format "Generating indexes"

    mkdir -p ${SHARED_INDEX_BASE}/project/${PROJECT_ID}/indexes

    /opt/idea/bin/${IDE_SHORT}.sh dump-shared-index project \
        --project-dir=${IDEA_PROJECT_DIR} \
        --project-id=${PROJECT_ID} \
        --commit-id=${COMMIT_ID} \
        --tmp=${SHARED_INDEX_BASE}/temp \
        --output=${SHARED_INDEX_BASE}/project/${PROJECT_ID}/indexes
#
#    mkdir -p ${SHARED_INDEX_BASE}/project/${PROJECT_ID}/indexes && \
#        mv ${SHARED_INDEX_BASE}/output/* ${SHARED_INDEX_BASE}/project/${PROJECT_ID}/indexes && \
#        rmdir ${SHARED_INDEX_BASE}/output
fi

# Format for CDN (cdn-layout-tool)
if [ "$SKIP_FORMAT" = "false" ]; then
    echo_format "Formatting indexes"

    /opt/cdn-layout-tool/bin/cdn-layout-tool \
        --indexes-dir=${SHARED_INDEX_BASE} \
        --url=${INDEXES_CDN_URL}

fi

# Generate config file for project (your-project/intellij.yaml)
if [ "$SKIP_CONFIG_FILE" = "false" ]; then
    echo_format "Creating intellij.yaml file"
    config_yaml="sharedIndex:\n  project:\n    - url: $INDEXES_CDN_URL/project/$PROJECT_ID\n"

    # Check if intellij.yaml already exists in project, if not create one
    if [ -f "$IDEA_PROJECT_DIR/intellij.yaml" ]; then
        echo "note: Your project already has an intellij.yaml file. Be sure to add the following to it:\n"
        echo "$config_yaml"
    else 
        touch "$IDEA_PROJECT_DIR/intellij.yaml"
        echo "$config_yaml"  >> "$IDEA_PROJECT_DIR/intellij.yaml"
        echo "Wrote the following to intellij.yaml:\n"
        echo "$config_yaml"
        echo "Be sure to commit this file to source control so others can use it."
    fi
fi