FROM elixir:1.5-alpine

EXPOSE 4000
ENV MIX_ENV=dev

RUN apk add --update \
    postgresql-client \
    git \
    make \
    alpine-sdk \

 && mix local.hex --force \
 && mix local.rebar --force

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN mix do deps.get --only $MIX_ENV, deps.compile

CMD ["iex"]
