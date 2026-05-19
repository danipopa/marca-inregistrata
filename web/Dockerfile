# syntax=docker/dockerfile:1

FROM docker.io/library/node:22-slim AS base

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --frozen-lockfile 2>/dev/null || npm install

COPY . .

FROM docker.io/library/node:22-slim AS runtime
FROM base AS build
RUN npm run build

WORKDIR /app

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3000
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

COPY --from=build /app/.output ./output

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
CMD ["node", "output/server/index.mjs"]
