# Build stage: Flutter web
FROM ghcr.io/cirruslabs/flutter:3.22.2 AS build
WORKDIR /app
COPY . .
RUN flutter config --enable-web \
    && flutter pub get \
    && flutter build web --release --web-renderer html

# Runtime stage: nginx serving static site and proxying /api to localhost:8000 (ACI)
FROM nginx:1.25-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
