### combined Dockerfile for the web app AND task worker
### use docker-compose.yml using the same image twice and providing two working_dir and two command elements
FROM python:alpine

### use with --build-arg GIT_PAT=git_token for private repo with uv
# ARG GIT_PAT
# RUN apk add git sed

### Grab UV binaries
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

### set work dir
RUN mkdir /app
WORKDIR /app



### copy reqs

### for pip
# ADD ./requirements.txt /app/requirements.txt

### for uv
COPY ./.python-version /app/
COPY ./pyproject.toml /app/pyproject.toml
COPY ./uv.lock /app/uv.lock
### for private repo with uv
# RUN sed -i 's|https://github.com|https://PRIVATE_REPO_USER@github.com|g' uv.lock



### install reqs in first layer (for efficiency) (global install)

### for pip
# RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

### for uv
ENV UV_PROJECT_ENVIRONMENT="/usr/local/"
RUN uv sync --no-cache --locked
### use --no-dev for prod builds
### ignore --no-dev and install private repo as a dev dep for dev builds

### install private library from github ; use for prod builds
### RUN uv add git+https://PRIVATE_REPO_USER:${GIT_PAT}@github.com/REPO_USER/REPO_NAME

### copy project files
### only for deployment container without watch directive
# COPY . /app/

### only for deployment container without docker-compose.yml template
# COMMAND = []
