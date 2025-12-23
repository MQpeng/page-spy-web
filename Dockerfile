FROM node:20 AS web
WORKDIR /app
ARG BASE_NAME=/page-spy-web
ENV VITE_BASE_NAME=$BASE_NAME
COPY . .
RUN (yarn install --ignore-optional && npm run build:client) || true

FROM golang:1.23 AS backend
WORKDIR /app
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/. .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM nginx:alpine
WORKDIR /app
COPY --from=backend /app/main /app/main
RUN chmod +x /app/main || true
COPY --from=web /app/dist /etc/nginx/html/page-spy-web
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
# Run the app in background and keep nginx in foreground
CMD ["sh","-c","/app/main & nginx -g 'daemon off;'"]
