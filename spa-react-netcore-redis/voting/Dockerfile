## This Dockerfile is used by App Engine Demo

FROM mcr.microsoft.com/dotnet/aspnet:2.1 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:2.1 AS build
# Install Node.js
RUN apt-get install --yes curl 
RUN curl --silent  --location https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install --yes nodejs build-essential
WORKDIR /src
COPY voting/voting.csproj voting/
RUN dotnet restore voting/voting.csproj
COPY voting voting/
WORKDIR /src/voting
RUN dotnet build voting.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish voting.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "voting.dll"]
