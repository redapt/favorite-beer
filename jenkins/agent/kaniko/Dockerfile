FROM gcr.io/kaniko-project/executor:debug
COPY ./config.json /kaniko/.docker/config.json
EOF

cat > config.json<<EOF
{ "credsStore": "ecr-login" }