[private]
default:
    @just --choose

# compile the site program
build:
    elm make src/Main.elm --output=site/main.js

# run the office tests
test:
    elm-test

# serve site/ with nginx
serve:
    docker run --rm --name historias-sinistras -p 8080:80 -v "{{justfile_directory()}}/site:/usr/share/nginx/html:ro" nginx
