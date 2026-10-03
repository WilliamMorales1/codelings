# docker4 -- keeping secrets out of the build context
#
# `docker build .` sends the whole directory (the "build context") to the
# builder, and `COPY . .` copies all of it into a layer. Anything that lands
# in a layer can be pulled back out by anyone who can pull the image, even if
# a later RUN deletes it.
#
# .dockerignore decides what never leaves your machine in the first place.
#
# Task: fix .dockerignore so the image does NOT contain
#   .env               (real credentials)
#   secrets/           (a deploy key)
#   NOTES.md           (internal notes)
# while public/index.html still ends up in /app/public/.
# (Keep the Dockerfile as it is; the fix belongs in .dockerignore.)
#
#   docker build -t opslings/docker4 .
#   docker run --rm opslings/docker4 find /app
#

FROM busybox:1.36
WORKDIR /app
COPY . .
CMD ["httpd", "-f", "-p", "8080", "-h", "/app/public"]
