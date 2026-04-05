# ── Build stage ───────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files and restore
COPY StudentManagement.Core/StudentManagement.Core.csproj           StudentManagement.Core/
COPY StudentManagement.Infrastructure/StudentManagement.Infrastructure.csproj StudentManagement.Infrastructure/
COPY StudentManagement.API/StudentManagement.API.csproj             StudentManagement.API/
RUN dotnet restore StudentManagement.API/StudentManagement.API.csproj

# Copy everything and publish
COPY . .
RUN dotnet publish StudentManagement.API/StudentManagement.API.csproj \
    -c Release -o /app/publish --no-restore

# ── Runtime stage ──────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create logs directory
RUN mkdir -p logs

COPY --from=build /app/publish .

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "StudentManagement.API.dll"]
