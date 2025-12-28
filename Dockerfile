# Build Frontend
FROM node:lts-alpine AS frontend-build

# Install tools
RUN apk add --no-cache make

# Install Elm
RUN npm install -g elm --unsafe-perm=true

WORKDIR /src

# Copy package files
COPY frontend/elm.json .
COPY frontend/Makefile .

# Copy source
COPY frontend/src/ src/
COPY frontend/style.css .
COPY frontend/index.html .

# Build
RUN make all

# Build Backend
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS backend-build
WORKDIR /src
COPY backend/backend.csproj .
RUN dotnet restore
COPY backend/ .
RUN dotnet publish -c Release -o /app/publish

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=backend-build /app/publish .
# Copy frontend dist to wwwroot
COPY --from=frontend-build /src/dist ./wwwroot

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "backend.dll"]
