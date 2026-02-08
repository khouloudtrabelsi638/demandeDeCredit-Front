FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps && npm cache clean --force
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build -- --configuration production --base-href / --output-path=dist/app

FROM nginx:alpine
LABEL maintainer="khouloudtrabelsi08@gmail.com"
LABEL version="1.0"
LABEL description="Frontend Angular - Demande de Credit"

RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/app /usr/share/nginx/html

# Fix permissions (nginx user already exists in base image)
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

EXPOSE 80
# DON'T switch to nginx user - causes read-only filesystem issues
CMD ["nginx", "-g", "daemon off;"]
