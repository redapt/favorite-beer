FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk AS build
# Install Node.js
RUN apt-get install --yes curl
RUN curl --silent  --location https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install --yes nodejs
RUN apt-get install --yes build-essential
WORKDIR /src
COPY voting/voting.csproj voting/
RUN dotnet restore voting/voting.csproj
COPY . .
WORKDIR /src/voting
RUN dotnet build voting.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish voting.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

EXPOSE 80
ENTRYPOINT ["dotnet", "voting.dll"]
