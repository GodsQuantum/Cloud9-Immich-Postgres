FROM pgvector/pgvector:0.8.5-pg18 AS pgvector

FROM postgres:18-bookworm
ARG VECTORCHORD_VERSION=1.1.1
ARG TARGETARCH # BuildKit supplies native target: amd64 or arm64

COPY --from=pgvector /usr/lib/postgresql/18/lib/vector.so /usr/lib/postgresql/18/lib/vector.so
COPY --from=pgvector /usr/share/postgresql/18/extension/vector.control /usr/share/postgresql/18/extension/vector.control
COPY --from=pgvector /usr/share/postgresql/18/extension/vector--*.sql /usr/share/postgresql/18/extension/

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates wget \
 && wget -nv -O /tmp/vchord.deb "https://github.com/tensorchord/VectorChord/releases/download/${VECTORCHORD_VERSION}/postgresql-18-vchord_${VECTORCHORD_VERSION}-1_${TARGETARCH}.deb" \
 && apt-get install -y /tmp/vchord.deb \
 && rm -f /tmp/vchord.deb \
 && apt-get purge -y wget \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/postgresql /var/postgresql-conf-tpl && chmod 1777 /etc/postgresql
COPY postgresql.hdd.conf postgresql.ssd.conf /var/postgresql-conf-tpl/
COPY immich-docker-entrypoint.sh healthcheck.sh set-env.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/immich-docker-entrypoint.sh /usr/local/bin/healthcheck.sh /usr/local/bin/set-env.sh

ENV DB_STORAGE_TYPE=SSD
HEALTHCHECK --interval=5m --start-interval=5s --start-period=5m CMD /usr/local/bin/healthcheck.sh
ENTRYPOINT ["/usr/local/bin/immich-docker-entrypoint.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
LABEL org.opencontainers.image.source="https://github.com/GodsQuantum/Cloud9-Immich-Postgres" \
      com.cloud9.upstream.source="https://github.com/immich-app/immich" \
      org.opencontainers.image.title="Cloud9-Immich-Postgres" \
      org.opencontainers.image.description="Immich-compatible PostgreSQL 18 with pgvector 0.8.5 and VectorChord 1.1.1, storage-aware config and safe filesystem enforcement" org.opencontainers.image.description="PostgreSQL18 + VectorChord1.1.1 + pgvector0.8.5 compatible with Immich"
