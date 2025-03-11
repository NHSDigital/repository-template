#!/bin/bash

set -euo pipefail

# Script to synchronise the nhs-notify-template-repository with this repository
#
# Usage:
#   $ [options] ./sync-template-repo.sh
#
# Options:
#   new_only=true      # Only identify new files from the template-repository
#   changes_only=true  # Only identify files which have drifted from the template-repository

# ==============================================================================

scriptdir=$(realpath "$(dirname "$0")")

# Command line parameters
new_only=${new_only:-false}
changes_only=${changes_only:-false}

# Set variables
TEMPLATE_REPO_DIR="nhs-notify-repository-template"
IGNORE_FILE="scripts/config/.repository-template-sync-ignore"
MERGE_FILE="scripts/config/.repository-template-sync-merge"

# Check if the template directory exists
if [ ! -d "${TEMPLATE_REPO_DIR}" ]; then
  echo "Template directory ${TEMPLATE_REPO_DIR} not found!"
  exit 1
fi

# Check if the .template-ignore file exists, create an empty one if not
if [ ! -f "${IGNORE_FILE}" ]; then
  echo "# Files and folders to ignore when syncing ${TEMPLATE_REPO_DIR} back in to this repository" > ${IGNORE_FILE}
  echo "# Files and Folders in this repository to ignore" >> ${IGNORE_FILE}
  echo "# Files and Folders in the template repository to disregard" >> ${IGNORE_FILE}
fi

# Check if the .template-merge file exists, create an empty one if not
if [ ! -f "${MERGE_FILE}" ]; then
  echo "# Files and folders to merge when syncing ${TEMPLATE_REPO_DIR} back in to this repository" > ${MERGE_FILE}
fi

TMP_SYNC_IGNORE=${PWD}/tmp-sync-ignore
mkdir -p "${TMP_SYNC_IGNORE}"
cp "${IGNORE_FILE}" "${TMP_SYNC_IGNORE}/.gitignore"

TMP_SYNC_MERGE=${PWD}/tmp-sync-merge
mkdir -p "${TMP_SYNC_MERGE}"
cp "${MERGE_FILE}" "${TMP_SYNC_MERGE}/.gitignore"

# Check if a file is ignored.
is_ignored() {
  local file=${1}

  # Ignore .git directories and files
  if [[ "$file" == *.git/* ]]; then
    return 0
  fi

  pushd "${TMP_SYNC_IGNORE}" > /dev/null
  git check-ignore -q "${file}"
  R=$?
  popd > /dev/null
  return $R
}

is_merge() {
  local file=${1}

  pushd "${TMP_SYNC_MERGE}" > /dev/null
  git check-ignore -q "${file}"
  R=$?
  popd > /dev/null
  return $R
}

# Navigate to the template directory
pushd "${TEMPLATE_REPO_DIR}" || exit
FILES_ADDED=()
FILES_WITH_CHANGES=()

# Loop through all files in the template directory
while IFS= read -r -d '' file || [[ -n $file ]]; do
  relative_path="${file#./}"  # Remove leading './'

  # Check if the file is ignored
  if is_ignored "$relative_path"; then
    echo "Ignoring $relative_path"
    continue
  fi

  target_path="../$relative_path"
  mkdir -p "$(dirname "$target_path")"

  # Copy the file to the root directory if it doesn't exist or is different
  if [ ! -f "$target_path" ] && [ "$changes_only" == false ]; then
    echo "Copying $relative_path to the repository"
    FILES_ADDED+=("${relative_path}")
    cp "$file" "$target_path"

  else
    # If the file exists, check if it's different
    if [ "$new_only" == false ]; then
      if ! diff -q "$file" "$target_path" > /dev/null 2>&1; then
        if is_merge "$relative_path"; then
          echo "Merging changes from $relative_path"
          cp "$target_path" "${target_path}.bak"
          node "${scriptdir}/../maintenance/merge.js" "$target_path" "$file" > "${target_path}.merged"
          if ! cmp -s "${target_path}.merged" "${target_path}.bak"; then
            FILES_WITH_CHANGES+=("${relative_path}")
            mv "${target_path}.merged" "$target_path"
          fi
          rm -f "${target_path}.merged" "${target_path}.bak"
        else
          echo "Copying changes from $relative_path"
          cp "$file" "$target_path"
          FILES_WITH_CHANGES+=("${relative_path}")
        fi
      fi
    fi
  fi
done < <(find . -type f -print0)

popd
rm -rf "${TMP_SYNC_IGNORE}" "${TMP_SYNC_MERGE}"

echo ------------------------------------------
echo "${#FILES_ADDED[@]} files added, ${#FILES_WITH_CHANGES[@]} files with changes detected."

if [[ "$changes_only" == false && ${#FILES_ADDED[@]} -gt 0 ]]; then
  echo ------------------------------------------
  echo "New files added:"
  printf ' - %s\n' "${FILES_ADDED[@]}"
fi

if [[ "$new_only" == false && ${#FILES_WITH_CHANGES[@]} -gt 0 ]]; then
  echo ------------------------------------------
  echo "Changed files:"
  printf ' - %s\n' "${FILES_WITH_CHANGES[@]}"
fi

echo ------------------------------------------
