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

sed -i '/<\/head>/i\
<script async src="https://www.googletagmanager.com/gtag/js?id=G-J5L38PDYTT"></script>\
<script>\
window.dataLayer = window.dataLayer || [];\
function gtag(){dataLayer.push(arguments);}\
gtag("js", new Date());\
gtag("config", "G-J5L38PDYTT");\
</script>' DMRpp.html

# Now we set up the git repo
git config --global init.defaultBranch "main"
git init
git config user.name "${GIT_USER_NAME}"
git config user.email "{GIT_USER_EMAIL}"
# Add and commit the content
git add .
git status
git commit -m "COMMIT Deploying update to GitHub Pages"
git status
# Push to GitHub Pages
git push --force -v "https://${GIT_UID}:${GIT_TOKEN}@github.com/OPENDAP/DMRpp-wiki" main:gh-pages
git status
