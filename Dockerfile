# Étape 1: Build Angular
FROM node:18-alpine AS builder

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances avec legacy-peer-deps pour éviter les conflits
RUN npm install --legacy-peer-deps && \
    npm install @angular/cdk@19.0.0 --legacy-peer-deps

# Copier le reste du projet
COPY . .

# Build de production
RUN npm run build -- --configuration production

# Étape 2: Serveur Nginx
FROM nginx:alpine

# Copier la configuration nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/dist/sakai-ng/browser /usr/share/nginx/html/browser

# Vérifier que les fichiers sont présents (debug)
RUN ls -la /usr/share/nginx/html/browser && \
    cat /usr/share/nginx/html/browser/index.html | head -5

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
