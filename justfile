[private]
default:
    @just --choose

# compile the site and write hashed assets to dist/
build:
    #!/usr/bin/env bash
    set -euo pipefail
    elm make src/Main.elm --output=site/main.js
    rm -rf dist && mkdir dist && cp -r site/fonts dist/
    h() { sha256sum "$1" | cut -c1-10; }
    js="main.$(h site/main.js).js"
    css="style.$(h site/style.css).css"
    casos="casos.$(h site/casos.json).json"
    cp site/main.js "dist/$js"
    cp site/style.css "dist/$css"
    cp site/casos.json "dist/$casos"
    sed -e "s|\"main.js\"|\"$js\"|" -e "s|\"style.css\"|\"$css\"|" -e "s|\"casos.json\"|\"$casos\"|" site/index.html > dist/index.html
    for f in "$js" "$css" "$casos"; do grep -q "\"$f\"" dist/index.html || { echo "index.html missing $f" >&2; exit 1; }; done

# run the office tests
test:
    elm-test

# serve site/ with nginx
serve:
    docker run --rm --name historias-sinistras -p 8080:80 -v "{{justfile_directory()}}/site:/usr/share/nginx/html:ro" nginx

# serve dist/ with nginx (post-build)
serve-dist:
    docker run --rm --name historias-sinistras -p 8080:80 -v "{{justfile_directory()}}/dist:/usr/share/nginx/html:ro" nginx