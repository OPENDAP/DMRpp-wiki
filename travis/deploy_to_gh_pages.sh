#!/bin/bash

cd output

GUIDE_FILE="DMRpp.html"
echo "GUIDE_FILE: ${GUIDE_FILE}"
ls -l ${GUIDE_FILE}

GUIDE_VERSION=`cat ../VERSION`"-${TRAVIS_BUILD_NUMBER}"
echo "GUIDE_VERSION: ${GUIDE_VERSION}"

index_html=$(
cat <<EOF
<!DOCTYPE html>
<html>
   <head>
      <title>DMR++ ${GUIDE_VERSION}</title>
      <meta http-equiv="refresh" content ="0; url=${GUIDE_FILE}" />
   </head>
   <body>
      <p>Redirecting to ${GUIDE_FILE}</p>
   </body>
</html>
EOF
)

cp -R ../images images

# GitHub Pages requires an functional index.html file.
# Here we add an index.html that redirects to DMRpp.html
echo "${index_html}" | tee index.html

# Now we set up the git repo
git init
git config user.name "${GH_USER_NAME}"
git config user.email "{GH_USER_EMAIL}"

# Add and commit the content
git add .
git status
git commit -m "COMMIT Deploying update to GitHub Pages"
git status
# Push to GitHub Pages
git push --force -v "https://${GH_TOKEN}@${GH_REF}" main:gh-pages; echo $?
git status
