# syntax=docker/dockerfile:1

FROM node:22-slim AS base

WORKDIR /app

# Install dependencies
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm install --frozen-lockfile 2>/dev/null || npm install

# Build stage
FROM base AS build
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG NUXT_PUBLIC_API_BASE_URL
ARG NUXT_PUBLIC_GOOGLE_CLIENT_ID
ENV NUXT_PUBLIC_API_BASE_URL=$NUXT_PUBLIC_API_BASE_URL
ENV NUXT_PUBLIC_GOOGLE_CLIENT_ID=$NUXT_PUBLIC_GOOGLE_CLIENT_ID
ENV NODE_ENV=production
RUN npm run build

# Production stage — only the built output
FROM node:22-slim AS final

WORKDIR /app
USER node

COPY --chown=node:node --from=build /app/.output ./output

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

EXPOSE 3000

CMD ["node", "output/server/index.mjs"]
