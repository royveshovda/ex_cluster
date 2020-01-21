FROM bitwalker/alpine-elixir-phoenix:latest AS phx-builder

ENV MIX_ENV=prod
ADD . .
RUN mix deps.get --only prod
RUN mix compile
RUN mix release


FROM alpine:3.10

RUN apk add --no-cache openssl
RUN apk add --no-cache ncurses-libs

ENV  MIX_ENV=prod

COPY --from=phx-builder /opt/app/_build/prod /opt/app/_build/prod

#EXPOSE 80
#EXPOSE 17012
#EXPOSE 4369
#EXPOSE 4370

WORKDIR /opt/app/_build/prod/rel/ex_cluster/bin/

CMD ["/opt/app/_build/prod/rel/ex_cluster/bin/ex_cluster", "start"]
