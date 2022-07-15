currentBranch=$GIT_BRANCH
git fetch origin release
git checkout release
VERSION=$(cat VERSION)
VERSION="${VERSION#[vV]}"
VERSION_MAJOR="${VERSION%%\.*}"
VERSION_MINOR="${VERSION#*.}"
VERSION_MINOR="${VERSION_MINOR%.*}"
VERSION_PATCH="${VERSION##*.}"

echo "Version: ${VERSION}"
echo "Version [major]: ${VERSION_MAJOR}"
echo "Version [minor]: ${VERSION_MINOR}"
echo "Version [patch]: ${VERSION_PATCH}"

git checkout $currentBranch