FROM mcr.microsoft.com/dotnet/sdk:6.0

WORKDIR /home/app

COPY . .

RUN dotnet restore

RUN dotnet publish ./avg.NET.csproj -o /publish/

WORKDIR /publish

#ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "avg.NET.dll"]