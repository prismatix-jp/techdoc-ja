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
  && pip3 install awscli


###############################################################################
# install RedPen

ENV REDPEN_VERSION 1.10.1

RUN wget -nv -O - https://github.com/redpen-cc/redpen/releases/download/redpen-${REDPEN_VERSION}/redpen-${REDPEN_VERSION}.tar.gz | tar zx -C /opt
ENV PATH $PATH:/opt/redpen-distribution-${REDPEN_VERSION}/bin


###############################################################################
# install textlint

RUN npm install -g \
    textlint \
    textlint-rule-no-todo \
    textlint-rule-no-start-duplicated-conjunction \
    textlint-rule-prh \
    textlint-rule-max-number-of-lines \
    textlint-rule-max-comma \
    textlint-rule-no-exclamation-question-mark \
    textlint-rule-no-dead-link \
    textlint-rule-editorconfig \
    textlint-rule-no-empty-section \
    textlint-rule-date-weekday-mismatch \
    textlint-rule-terminology \
    textlint-rule-period-in-list-item \
    textlint-rule-no-nfd \
    textlint-rule-no-surrogate-pair \
    textlint-rule-common-misspellings \
    textlint-rule-max-ten \
    textlint-rule-max-kanji-continuous-len \
    textlint-rule-spellcheck-tech-word \
    textlint-rule-web-plus-db \
    textlint-rule-no-mix-dearu-desumasu \
    textlint-rule-no-doubled-joshi \
    textlint-rule-no-double-negative-ja \
    textlint-rule-no-hankaku-kana \
    textlint-rule-ja-no-weak-phrase \
    textlint-rule-ja-no-redundant-expression \
    textlint-rule-ja-no-abusage \
    textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet \
    textlint-rule-sentence-length \
    textlint-rule-no-dropping-the-ra \
    textlint-rule-no-doubled-conjunctive-particle-ga \
    textlint-rule-no-doubled-conjunction \
    textlint-rule-ja-no-mixed-period \
    textlint-rule-ja-yahoo-kousei \
    textlint-rule-max-appearence-count-of-words \
    textlint-rule-max-length-of-title \
    textlint-rule-incremental-headers \
    textlint-rule-ja-unnatural-alphabet \
    @textlint-ja/textlint-rule-no-insert-dropping-sa \
    textlint-rule-preset-ja-technical-writing \
    textlint-rule-preset-jtf-style \
    textlint-rule-preset-ja-spacing \
    textlint-rule-preset-japanese \
    textlint-filter-rule-whitelist \
    textlint-filter-rule-comments \
    textlint-filter-rule-node-types


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
ENV PATH $PATH:/opt/calibre/bin
