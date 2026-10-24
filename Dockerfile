FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

# restore first, so the packages are cached until the project file changes
COPY avg.NET.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish ./avg.NET.csproj -c Release --no-restore -o /publish/

FROM mcr.microsoft.com/dotnet/aspnet:10.0

WORKDIR /app
COPY --from=build /publish .

# run as the non-root user of the image. listens on port 8080 (ASPNETCORE_HTTP_PORTS)
USER app
EXPOSE 8080

ENTRYPOINT ["dotnet", "avg.NET.dll"]
