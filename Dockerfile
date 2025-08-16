# syntax=docker/dockerfile:1
FROM node:20-alpine

# small tools for debug/health
RUN apk add --no-cache bash curl

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

# drop privileges
USER node

EXPOSE 8080
ENV PORT=8080
CMD ["npm", "start"]