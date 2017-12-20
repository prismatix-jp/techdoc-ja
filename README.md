# techdoc-ja

日本語で情報技術ドキュメント（仕様書やドキュメント等）を記述するための、オーサリング環境を提供します。


## 要件

- ドキュメントを Markdown 形式で記述する。
    - コードブロックのシンタックスハイライトに対応する。
    - PlantUML による作図に対応する。
    - 日本語の記述に対応する。（PlantUML 内も含めて）
- GitHub でドキュメントプロジェクトを管理し、PR で編集する。
- Circle CI によって継続的に、次の処理を実行する。
    - RedPen および textlint により文章の自動校正をする。
    - Gitbook によって、HTML および PDF 出力を得る。
    - 出力結果は Amazon S3 にデプロイする。


## 成果物

前述の Circle CI による処理のために、下記のソフトウェアを利用します。

- Node.js v9.3.0
- OpenJDK 1.8.0_131
- RedPen 1.10.1
- textlint v10.0.0
- GitBook 3.2.2
- graphviz version 2.38.0 (20140413.2041)
- Python/3.4.2
- aws-cli 1.14.11

これらをインストールした Docker イメージおよびその利用方法を、本プロジェクトの成果物とします。


## 利用方法

### 標準プロジェクト構成

ドキュメントプロジェクトは、次のディレクトリ構成を標準とします。

```
.
+-- README.md            -- ドキュメントの運用・ビルド方法等
+-- .circleci
|   +-- config.yml       -- Circle CI 設定（後述）
|
+-- .gitignore           -- git 設定（後述）
+-- book.json            -- Gitbook 設定（後述）
+-- config               -- 校正ツール設定
|   +-- redpen-conf.xml  -- RedPen 設定（後述）
|   +-- redpen-dict
|       +-- stopwords.txt
|       +-- suggest.txt
|       +-- katakana.txt
|   +-- textlint.json    -- textlint 設定（後述）
|   +-- ...
|
+-- content
|   +-- README.md        -- ドキュメント本体の README
|   +-- SUMMARY.md       -- 目次等
|   +-- ...              -- その他コンテンツ
|   +-- styles
|       +-- website.css
|       +-- pdf.css
|
+-- _book                -- ビルド成果物
    +-- index.html
    +-- techdoc-example.pdf
    +-- ...
```

### Gitbook 設定例 (book.json)

```json
{
  "root": "./content",
  "language": "ja",
  "title": "情報技術ドキュメント例",
  "styles": {
    "website": "styles/website.css",
    "pdf": "styles/pdf.css"
  },
  "pdf": {
    "fontSize": 11,
    "fontFamily": "MigMix 1P"
  },
  "plugins": [
    "include",
    "include-codeblock",
    "uml",
    "-sharing",
    "alerts",
    "back-to-top-button",
    "ace"
  ],
  "pluginsConfig": {
    "include-codeblock": {
      "template": "acefull"
    }
  }
}
```

### Circle CI 設定例 (.circleci/config.yml)

```yaml
version: 2
jobs:
  build:
    working_directory: ~/workspace
    docker:
      - image: dai0304/docker-techdoc-ja:latest
    steps:
      - checkout
      - restore_cache:
          keys:
            - techdoc-{{ .Branch }}-{{ .Revision }}
            - techdoc-{{ .Branch }}
      - run:
          name: System information
          command: |
            echo "Node $(node -v)"
            java -version
            echo "RedPen $(redpen -v)"
            echo "textlint $(textlint -v)"
            gitbook current
            dot -V
            aws --version
      - run:
          name: Check by RedPen
          command: find ./content -name "*.md" -type f | xargs redpen ${REDPEN_OPTS} -l 0 -L ja -f markdown -c ./config/redpen-conf.xml
      - run:
          name: Check by textlint
          command: textlint ${TEXTLINT_OPTS} --config ./config/textlint.json ./content
      - run:
          name: Build
          command: |
            gitbook install
            gitbook build .
            if [ -n "${PDF_FILENAME}" ]; then
              gitbook pdf . _book/${PDF_FILENAME}
            fi
      - store_artifacts:
          name: Store artifacts
          path: _book
          destination: _book
      - deploy:
          name: Deploy artifacts
          command: |
            if [ -n "${AWS_S3_LOCATION_MASTER}" -a "${CIRCLE_BRANCH}" == "master" ]; then
              DEPLOY_LOCATION=${AWS_S3_LOCATION_MASTER}
            elif [ -n "${AWS_S3_LOCATION_SNAPSHOT}" ]; then
              DEPLOY_LOCATION=${AWS_S3_LOCATION_SNAPSHOT%/}/${CIRCLE_BRANCH}
            fi
            if [ -n "${DEPLOY_LOCATION}" ]; then
              aws s3 sync _book ${DEPLOY_LOCATION} --delete
            fi
      - save_cache:
          key: techdoc-{{ .Branch }}-{{ .Revision }}
          paths:
            - ~/workspace/node_modules
```

#### Circle CI に設定できる環境変数

| 環境変数名                 | 説明                                             | 例
| -------------------------- | ------------------------------------------------ | ----
| `REDPEN_OPTS`              | RedPen のコマンドライン引数                      | 
| `TEXTLINT_OPTS`            | textlint のコマンドライン引数                    | `--debug`
| `PDF_FILENAME`             | PDFを出力する場合は、その出力ファイル名          | `foobar.pdf`
| `AWS_S3_LOCATION_MASTER`   | master ブランチをデプロイする場合は、その S3 URI | `s3://ex-bucket/release/`
| `AWS_S3_LOCATION_SNAPSHOT` | その他ブランチをデプロイする場合は、その S3 URI  | `s3://ex-bucket/snapshot/`

### RedPen 設定例

```xml
<redpen-conf lang="ja">
  <validators>
    <validator name="SentenceLength" />
    <validator name="InvalidExpression">
      <property name="dict" value="redpen-dict/stopwords.txt"/>
    </validator>
    <validator name="CommaNumber" />
    <validator name="SuggestExpression">
      <property name="dict" value="redpen-dict/suggest.txt"/>
    </validator>
    <validator name="InvalidSymbol"/>
    <validator name="KatakanaEndHyphen">
      <property name="dict" value="redpen-dict/katakana.txt"/>
    </validator>
    <validator name="KatakanaSpellCheck"/>
    <validator name="SectionLength"/>
    <validator name="ParagraphNumber"/>
    <validator name="SpaceBetweenAlphabeticalWord"/>
    <validator name="SuccessiveWord"/>
    <validator name="DoubleNegative" />
    <validator name="FrequentSentenceStart" />
    <validator name="ParenthesizedSentence">
      <property name="max_nesting_level" value="1"/>
      <property name="max_count" value="3"/>
      <property name="max_length" value="10"/>
    </validator>
    <validator name="HankakuKana"/>
    <validator name="Okurigana"/>
    <validator name="GappedSection"/>
    <validator name="LongKanjiChain">
      <property name="max_len" value="6"/>
    </validator>
    <validator name="SectionLevel"/>
    <validator name="JapaneseAmbiguousNounConjunction" />
    <validator name="JapaneseJoyoKanji" />
    <validator name="JapaneseNumberExpression" />
    <validator name="JapaneseAnchorExpression" />
    <validator name="SuccessiveSentence" />
    <validator name="DoubledConjunctiveParticleGa" />
    <validator name="ListLevel" />
  </validators>
  <symbols>
    <symbol name="FULL_STOP" value="。" invalid-chars="．" />
    <symbol name="COMMA" value="、" invalid-chars="，"/>
    <symbol name="COLON" value=":" />
    <symbol name="AMPERSAND" value="&amp;" />
    <symbol name="QUESTION_MARK" value="?" />
    <symbol name="DOLLAR_SIGN" value="$" />
    <symbol name="LESS_THAN_SIGN" value="&lt;" />
    <symbol name="GREATER_THAN_SIGN" value="&gt;" />
    <symbol name="VERTICAL_BAR" value="|" />
    <symbol name="PERCENT_SIGN" value="%" />
    <symbol name="EXCLAMATION_MARK" value="!" />
    <symbol name="LEFT_CURLY_BRACKET" value="{" />
    <symbol name="RIGHT_CURLY_BRACKET" value="}" />
    <symbol name="EQUAL_SIGN" value="=" />
    <symbol name="LEFT_SQUARE_BRACKET" value="[" />
    <symbol name="RIGHT_SQUARE_BRACKET" value="]" />
    <symbol name="LEFT_PARENTHESIS" value="(" />
    <symbol name="RIGHT_PARENTHESIS" value=")" />
    <symbol name="AT_MARK" value="@" />
  </symbols>
</redpen-conf>
```

### textlint 設定例

```json
{
  "rules": {
    "spellcheck-tech-word": true,
    "preset-ja-technical-writing": {
      "no-exclamation-question-mark": false
    },
    "preset-jtf-style": {
      "3.1.1.全角文字と半角文字の間": false,
      "3.3.かっこ類と隣接する文字の間のスペースの有無": false
    },
    "preset-ja-spacing": {
      "ja-space-between-half-and-full-width": {
        "space": "always"
      },
      "ja-no-space-around-parentheses": false
    },
    "preset-japanese": {
      "sentence-length": false
    },
    "no-todo": true,
    "no-start-duplicated-conjunction": {
      "interval" : 2
    },
    "no-exclamation-question-mark": true,
    "no-dead-link": {
      "checkRelative": false,
      "baseURI": null,
      "ignore": []
    },
    "no-empty-section": true,
    "date-weekday-mismatch": true,
    "period-in-list-item": {
      "periodMarks": [".", "．"]
    },
    "no-nfd": true,
    "no-surrogate-pair": true,
    "common-misspellings": {
      "ignore": []
    },
    "ja-no-redundant-expression": true,
    "no-mixed-zenkaku-and-hankaku-alphabet": true,
    "textlint-rule-max-appearence-count-of-words": {
      "limit": 5
    },
    "textlint-rule-max-length-of-title": {
      "#": 25,
      "##": 30
    },
    "incremental-headers": true,
    "ja-unnatural-alphabet": true,
    "@textlint-ja/textlint-rule-no-insert-dropping-sa": true
  },
  "filters": {
    "comments": true,
    "whitelist": {
      "allow": [
        "ignored-word",
        "/\\d+/"
      ]
    }
  }
}
```

### .gitignore 設定例

下記コマンドで作成しましょう。

```
$ curl -s https://www.gitignore.io/api/node,gitbook >.gitignore
$ echo "/assets" >>.gitignore
```

### Circle CI と同等の環境下に入る方法

```
$ docker run --rm -it -v $(pwd):/root/workspace -w /root/workspace dai0304/docker-techdoc-ja sh
```

