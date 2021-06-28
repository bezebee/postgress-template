FROM gitpod/workspace-full

# Setup Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh

# Setup Python linters
RUN pip3 install flake8 flake8-flask flake8-django

# Setup Postgres
RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list' && \
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    sudo apt-get update -y && \
    sudo apt-get -y install links  && \
    sudo apt-get install -y postgresql-12

# Upgrade Node

ENV NODE_VERSION=14.15.4
RUN bash -c ". .nvm/nvm.sh && \
        nvm install ${NODE_VERSION} && \
        nvm alias default ${NODE_VERSION} && \
        npm install -g yarn"

RUN echo 'alias heroku_config=". $GITPOD_REPO_ROOT/.vscode/heroku_config.sh"' >> ~/.bashrc
RUN echo 'alias run="python3 $GITPOD_REPO_ROOT/manage.py runserver 0.0.0.0:8000"' >> ~/.bashrc
RUN echo 'alias python=python3' >> ~/.bashrc	
RUN echo 'alias pip=pip3' >> ~/.bashrc	
RUN echo 'alias font_fix="python3 $GITPOD_REPO_ROOT/.vscode/font_fix.py"' >> ~/.bashrc

ENV PATH=/usr/lib/postgresql/12/bin:/home/gitpod/.nvm/versions/node/v${NODE_VERSION}/bin:$PATH
ENV PGDATA="/workspace/.pgsql/data"

RUN mkdir -p ~/.pg_ctl/bin ~/.pg_ctl/sockets \
    && echo '#!/bin/bash\n[ ! -d $PGDATA ] && mkdir -p $PGDATA && initdb --auth=trust -D $PGDATA\npg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" start\n' > ~/.pg_ctl/bin/pg_start \
    && echo '#!/bin/bash\npg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" stop\n' > ~/.pg_ctl/bin/pg_stop \
    && chmod +x ~/.pg_ctl/bin/*
ENV PATH="$PATH:$HOME/.pg_ctl/bin"
ENV DATABASE_URL="postgresql://gitpod@localhost"
ENV PGHOSTADDR="127.0.0.1"
ENV PGDATABASE="postgres"

# Local environment variables

ENV PORT="8080"
ENV IP="0.0.0.0"
