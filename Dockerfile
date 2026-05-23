FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

ENV VIRTUAL_ENV=/opt/hermes-venv
ENV PATH="/opt/hermes-venv/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates git vim openssh-client ripgrep && \
    rm -rf /var/lib/apt/lists/*

RUN uv venv "$VIRTUAL_ENV"

RUN git clone --depth 1 https://github.com/NousResearch/hermes-agent.git /tmp/hermes-agent && \
    cd /tmp/hermes-agent && \
    uv pip install --python "$VIRTUAL_ENV/bin/python" --no-cache -e ".[all]" && \
    rm -rf /tmp/hermes-agent/.git

COPY requirements.txt /app/requirements.txt
RUN uv pip install --python "$VIRTUAL_ENV/bin/python" --no-cache -r /app/requirements.txt

RUN mkdir -p /data/.hermes

COPY server.py /app/server.py
COPY templates/ /app/templates/
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENV HOME=/data
ENV HERMES_HOME=/data/.hermes

CMD ["/app/start.sh"]
