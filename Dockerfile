# Stage 1: resolve dependencies into an in-project venv
FROM python:3.12-slim-bookworm AS build

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_CACHE_DIR=/tmp/poetry_cache

RUN pip install --no-cache-dir poetry

WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN poetry install --only main --no-root && rm -rf $POETRY_CACHE_DIR

# Stage 2: runtime with Xvfb and the browser, no Poetry
FROM python:3.12-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Same base image as the build stage, so the venv's python symlinks stay valid.
COPY --from=build /app/.venv /app/.venv

# chrome or chromium, must match CHANNEL in .env (Google Chrome has no linux/arm64 build).
ARG BROWSER=chrome
RUN apt-get update \
    && apt-get install -y --no-install-recommends xvfb \
    && playwright install --with-deps ${BROWSER} \
    && rm -rf /var/lib/apt/lists/*

# start.sh is tracked as 100644, so set the exec bit here instead of relying on the checkout.
COPY --chmod=755 start.sh ./
COPY src ./src

ENTRYPOINT ["./start.sh"]
