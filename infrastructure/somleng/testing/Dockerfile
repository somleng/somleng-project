FROM public.ecr.aws/docker/library/alpine:latest

RUN apk update && apk upgrade && apk add --update --no-cache jq sipp curl

COPY --link tests tests

WORKDIR /tests
