npm ci

npm run generate-dependencies --workspaces --if-present

npm run lambda-build --workspaces --if-present
