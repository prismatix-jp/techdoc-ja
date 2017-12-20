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

これらをインストールした [Docker イメージ](https://hub.docker.com/r/classmethod/techdoc-ja/)
およびその[利用方法](usage.md)を、本プロジェクトの成果物とします。


