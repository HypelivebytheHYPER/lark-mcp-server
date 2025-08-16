# syntax=docker/dockerfile:1
FROM node:20-alpine

# small tools for debug/health
RUN apk add --no-cache bash curl

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

# drop privileges
USER node

EXPOSE 8080
CMD ["npm", "start"]
