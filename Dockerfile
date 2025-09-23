# Указываем версию Keycloak (замени на ту, что ты используешь)
ARG KC_VERSION=latest

### Stage 1: Builder
FROM quay.io/keycloak/keycloak:${KC_VERSION} AS builder

# Если у тебя есть theme или провайдер в локальной папке
# Копируем .jar провайдера
COPY dist_keycloak/keycloak-theme-for-kc-all-other-versions.jar /opt/keycloak/providers/

# Устанавливаем нужные env, если хочешь health, metrics etc.
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

WORKDIR /opt/keycloak

# Выполняем build, чтобы Keycloak “собрал” все, включая темы и провайдеры
RUN /opt/keycloak/bin/kc.sh build --db postgres

### Stage 2: Финальный образ
FROM quay.io/keycloak/keycloak:${KC_VERSION}

# Копируем из builder готовый Keycloak каталог
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Указываем точку входа — стандартный скрипт Keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

CMD ["start", "--optimized"]

# podman build --platform linux/amd64 -t docker.io/niktverd/keycloak-with-theme:latest . && podman push docker.io/niktverd/keycloak-with-theme:latest   
