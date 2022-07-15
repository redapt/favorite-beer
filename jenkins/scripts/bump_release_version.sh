export currentBranch=$(git branch | sed -n '/\* /s///p')
git fetch origin release
git checkout release
export VERSION=$(cat VERSION)
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