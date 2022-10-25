FROM node:alpine:latest as install
WORKDIR /install
COPY package.json /install/
RUN npm install --quiet

FROM node:alpine:latest as compile
WORKDIR /build
COPY tsconfig.json index.ts /build/
COPY --from=install /install/node_modules /build/node_modules
RUN node_modules/typescript/bin/tsc

FROM node:alpine:latest as source
WORKDIR /app
COPY --from=compile /build/index.js /app/index.js
COPY package.json /app
RUN npm install --production --quiet

FROM node:alpine:latest as dev
WORKDIR /app
COPY --from=source /app/index.js .
COPY --from=source /app/node_modules node_modules
VOLUME [ "/watch" ]
ENTRYPOINT [ "node" ]
CMD ["index.js"]

FROM node:alpine:latest as prod
WORKDIR /app
COPY --from=source /app/index.js .
COPY --from=source /app/node_modules node_modules
RUN mkdir /watch
ENTRYPOINT [ "node" ]
CMD ["index.js"]

FROM node:alpine:latest as copyless
WORKDIR /app
COPY  /app/index.js .
COPY /app/node_modules node_modules
RUN mkdir /watch
ENTRYPOINT [ "node" ]
CMD ["index.js"]
