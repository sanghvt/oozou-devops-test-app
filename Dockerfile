# Base stage for all environments
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./

# Development stage
FROM base AS development
ENV NODE_ENV=development
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

# UAT stage (for testing)
FROM base AS uat
ENV NODE_ENV=uat
RUN npm ci
COPY . .
CMD ["npm", "run", "start:uat"]

# Build stage for production artifacts
FROM base AS builder
RUN npm ci
COPY . .
RUN mkdir -p dist && cp index.js package*.json dist/

# Production stage
FROM node:18-alpine AS production
ENV NODE_ENV=production
WORKDIR /app
COPY --from=builder /app/dist ./
RUN npm ci --only=production
CMD ["npm", "start"] 