FROM node:9.3.0

LABEL maintainer "Daisuke Miyamoto <miyamoto.daisuke@classmethod.jp>"


###############################################################################
## setup

ENV LANG ja_JP.UTF-8
RUN echo "deb http://http.debian.net/debian jessie-backports main" >>/etc/apt/sources.list \
  && apt-get clean \
  && apt-get update \
  && apt-get install -y locales-all


###############################################################################
# install Java (for PlantUML, RedPen)

RUN apt-get install -y -qq -t jessie-backports openjdk-8-jdk \
  && update-java-alternatives --set java-1.8.0-openjdk-amd64


###############################################################################
# install AWS CLI (for deploy)

RUN apt-get install -y -qq python3-pip \
  && pip3 install awscli==1.14.11


###############################################################################
# install RedPen

ENV REDPEN_VERSION 1.10.1

RUN wget -nv -O - https://github.com/redpen-cc/redpen/releases/download/redpen-${REDPEN_VERSION}/redpen-${REDPEN_VERSION}.tar.gz | tar zx -C /opt
ENV PATH $PATH:/opt/redpen-distribution-${REDPEN_VERSION}/bin


###############################################################################
# install textlint

RUN npm install -g \
    textlint@10.0.0 \
    textlint-rule-no-todo@2.0.0 \
    textlint-rule-no-start-duplicated-conjunction@1.1.4 \
    textlint-rule-prh@5.0.1 \
    textlint-rule-max-number-of-lines@1.0.3 \
    textlint-rule-max-comma@1.0.4 \
    textlint-rule-no-exclamation-question-mark@1.0.2 \
    textlint-rule-no-dead-link@4.1.0 \
    textlint-rule-editorconfig@1.0.3 \
    textlint-rule-no-empty-section@1.1.0 \
    textlint-rule-date-weekday-mismatch@1.0.5 \
    textlint-rule-terminology@1.1.24 \
    textlint-rule-period-in-list-item@0.2.0 \
    textlint-rule-no-nfd@1.0.1 \
    textlint-rule-no-surrogate-pair@1.0.1 \
    textlint-rule-common-misspellings@1.0.1 \
    textlint-rule-max-ten@2.0.3 \
    textlint-rule-max-kanji-continuous-len@1.1.1 \
    textlint-rule-spellcheck-tech-word@5.0.0 \
    textlint-rule-web-plus-db@1.1.5 \
    textlint-rule-no-mix-dearu-desumasu@3.0.3 \
    textlint-rule-no-doubled-joshi@3.5.1 \
    textlint-rule-no-double-negative-ja@1.0.5 \
    textlint-rule-no-hankaku-kana@1.0.2 \
    textlint-rule-ja-no-weak-phrase@1.0.4 \
    textlint-rule-ja-no-redundant-expression@1.0.3 \
    textlint-rule-ja-no-abusage@1.2.1 \
    textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet@1.0.1 \
    textlint-rule-sentence-length@1.1.3 \
    textlint-rule-no-dropping-the-ra@1.1.2 \
    textlint-rule-no-doubled-conjunctive-particle-ga@1.0.2 \
    textlint-rule-no-doubled-conjunction@1.0.2 \
    textlint-rule-ja-no-mixed-period@2.0.0 \
    textlint-rule-ja-yahoo-kousei@1.0.3 \
    textlint-rule-max-appearence-count-of-words@1.0.1 \
    textlint-rule-max-length-of-title@1.0.1 \
    textlint-rule-incremental-headers@0.2.0 \
    textlint-rule-ja-unnatural-alphabet@1.3.0 \
    @textlint-ja/textlint-rule-no-insert-dropping-sa@1.0.1 \
    textlint-rule-preset-ja-technical-writing@2.0.0 \
    textlint-rule-preset-jtf-style@2.3.1 \
    textlint-rule-preset-ja-spacing@2.0.1 \
    textlint-rule-preset-japanese@2.0.0 \
    textlint-filter-rule-whitelist@1.2.3 \
    textlint-filter-rule-comments@1.2.2 \
    textlint-filter-rule-node-types@1.0.1

###############################################################################
# install markdownlint

RUN npm install -g markdownlint-cli@0.7.1

###############################################################################
# install gitbook

RUN npm install -g gitbook-cli && gitbook fetch 3.2.2

###############################################################################
# install Japanese font (for PDF)

RUN apt-get install -y -qq fonts-migmix


###############################################################################
# install graphviz (for PlantUML)

RUN apt-get install -y -qq graphviz


###############################################################################
# install Caribre (for PDF)

ENV CALIBRE_INSTALLER_SOURCE_CODE_URL https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py

RUN wget -O - ${CALIBRE_INSTALLER_SOURCE_CODE_URL} | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)"
ENV PATH $PATH:/opt/calibre
