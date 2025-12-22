FROM node:20 AS web
WORKDIR /app
ARG REGISTRY=https://registry.npmjs.org
ARG BASE_NAME=/page-spy-web
ENV VITE_BASE_NAME=$BASE_NAME
COPY . .
RUN yarn install --ignore-optional --registry $REGISTRY && yarn run build:client

FROM golang:1.23 AS backend
WORKDIR /app
COPY --from=web /app/dist ./dist
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/. .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest
WORKDIR /app
COPY --from=backend /app/main /app/main
CMD ["/app/main"]
