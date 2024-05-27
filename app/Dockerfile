# syntax=docker/dockerfile:experimental
FROM cgr.dev/chainguard/wolfi-base as builder

ENV GOPRIVATE="github.com/samsonannan/addon"

WORKDIR /

ARG SSH_PRIVATE_KEY

RUN apk update
RUN apk add --no-cache ca-certificates git openssh-keyscan openssh-keygen openssh-client

RUN git config --global url."ssh://git@github.com/".insteadOf "https://github.com/"

# RUN set -euo pipefail && \
#     mkdir -p -m 0600 ~/.ssh && \
#     ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
#     ssh-keygen -F github.com -l -E sha256
    #    | grep -q "SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8"

# RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN apk add --no-cache wget
RUN wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
RUN tar -xzf go1.22.3.linux-amd64.tar.gz

ENV PATH="/go/bin:${PATH}"

#RUN --mount=type=secret,id=gh_ssh_key if test -f /run/secrets/gh_ssh_key; then cp /run/secrets/gh_ssh_key ~/.ssh/id_ecdsa; fi

# Create SSH directory and set permissions
RUN mkdir -p ~/.ssh && \
    chmod 600 ~/.ssh

# Add SSH key and set permissions
RUN echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_ed25519 && \
    chmod 600 ~/.ssh/id_ed25519

# Add GitHub to known hosts to avoid SSH authenticity prompt
RUN ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts

# Ensure ssh-agent is running and the key is added
RUN echo $SSH_PRIVATE_KEY
RUN eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519

# RUN git config --global \
# url."https://samsonannan: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@github.com/samsonannan/addon".insteadOf \
# "https://github.com/samsonannan/addon"

COPY . .
# RUN mkdir -p ./services/rng
# COPY ./services/rng/go.mod ./services/rng
# COPY ./services/rng/go.sum ./services/rng
# COPY ./services/rng/ ./services/rng
RUN go mod download; CGO_ENABLED=0 GOOS=linux GO111MODULE=on ../../go/bin/go build -ldflags '-s -w -extldflags "-static"' ./cmd/server.go


FROM cgr.dev/chainguard/glibc-dynamic
WORKDIR /app
COPY --from=builder . /app
EXPOSE 9000
CMD ["./server"]