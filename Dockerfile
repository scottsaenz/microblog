FROM python:3.11-slim as buider
# FROM elasticsearch:8.13.0


# COPY --from=buider . .

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.8.2 \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_NO_COLOR=off \
    FLASK_APP="microblog.py"

WORKDIR /opt/microblog

RUN pip install "poetry==$POETRY_VERSION"
RUN python -m venv /venv

COPY poetry.lock pyproject.toml ./
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi



COPY app app
COPY migrations migrations
COPY microblog.py config.py .flaskenv boot.sh README.md ./


RUN flask translate compile






RUN chmod a+x boot.sh



EXPOSE 5000
ENTRYPOINT ["./boot.sh"]
