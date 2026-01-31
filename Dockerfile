# Stage 1: Build Angular
FROM node:18-alpine AS build
WORKDIR /app

# Copier uniquement package.json et package-lock.json pour accélérer le cache
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier le reste du projet
COPY . .

# Construire le projet Angular
RUN npm run build

# Stage 2: Nginx pour servir le frontend
FROM nginx:alpine

# Copier le build Angular dans le dossier de Nginx
COPY --from=build /app/dist/sakai-ng /usr/share/nginx/html/

# Exposer le port 80
EXPOSE 80

# Lancer Nginx
CMD ["nginx", "-g", "daemon off;"]
