#/bin/sh

echo_format() {
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

#adding /var/project to safe directory of git
if [ -d "${IDEA_PROJECT_DIR}/.git" ]; then
  git config --global --add safe.directory ${IDEA_PROJECT_DIR}
fi

# Format for CDN (cdn-layout-tool)

echo_format "Formatting indexes"

/opt/ij-shared-indexes-tool-cli/bin/ij-shared-indexes-tool-cli indexes \
    --ij "/opt/idea" \
    --project "${IDEA_PROJECT_DIR}/${PROJECT_NAME}" \
    --data-directory "${SHARED_INDEX_BASE}" \
    --base-url "${INDEXES_CDN_URL}"
