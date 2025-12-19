# Build Stage
FROM node:lts-alpine AS build

# Install tools
RUN apk add --no-cache make

# Install Elm
RUN npm install -g elm --unsafe-perm=true

WORKDIR /src

# Copy package files first to cache dependencies
COPY elm.json .
COPY Makefile .

# Copy source
COPY src/ src/
COPY style.css .
COPY index.html .

# Build
RUN make all

# Runtime Stage
FROM nginx:alpine

# Copy config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy build artifacts
COPY --from=build /src/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
