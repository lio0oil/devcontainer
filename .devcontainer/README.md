# devcontainer

devcontainer および Linux 環境の初期構成を行うセットアップスクリプト群。

## 環境詳細

### ベースイメージ

| 項目 | 内容 |
| --- | --- |
| イメージ | `mcr.microsoft.com/devcontainers/base:ubuntu` |
| ユーザー | `vscode` |

### シェル

| 項目 | 内容 |
| --- | --- |
| シェル | zsh |
| フレームワーク | Oh My Zsh |
| テーマ | devcontainers |
| プラグイン | zsh-completions / zsh-autosuggestions / zsh-syntax-highlighting / fzf |

### パッケージマネージャー

| ツール | 用途 |
| --- | --- |
| Homebrew | Linux 向けパッケージマネージャー。各種ツールのインストールに使用 |
| uv | Python バージョン・パッケージ管理 |
| Volta | Node.js バージョン管理 |
| SDKMAN | Java バージョン管理 |

### インストールされるツール（Homebrew）

| ツール | 用途 |
| --- | --- |
| gcc | C/C++ コンパイラ |
| jq | JSON 処理 |
| git | バージョン管理 |
| git-remote-codecommit | AWS CodeCommit 連携 |
| awscli | AWS CLI |
| aws-cdk | AWS CDK |
| docker | Docker CLI |

### 言語ランタイム

| 言語 | バージョン管理 | デフォルト |
| --- | --- | --- |
| Python | uv | 最新安定版 |
| Node.js | Volta | 最新安定版 |
| Java | SDKMAN | 最新 LTS |
| Go | goenv | 最新安定版（デフォルト無効） |
| Rust | rustup | stable（デフォルト無効） |

### AI CLI ツール

| ツール | インストール方法 | デフォルト |
| --- | --- | --- |
| Claude Code | curl インストーラー | 有効 |
| Gemini CLI | npm | 有効 |
| Kiro CLI | curl インストーラー | 有効 |

### VS Code 拡張機能

| 拡張機能 | 用途 |
| --- | --- |
| MS-CEINTL.vscode-language-pack-ja | 日本語 UI |
| esbenp.prettier-vscode | コードフォーマッター |
| ms-python.vscode-pylance | Python 言語サーバー |
| ms-python.python | Python サポート |
| charliermarsh.ruff | Python リンター・フォーマッター |
| amazonwebservices.aws-toolkit-vscode | AWS Toolkit |
| Boto3typed.boto3-ide | Boto3 補完 |
| mhutchie.git-graph | Git グラフ表示 |
| eamodio.gitlens | Git 拡張 |

### マウント

| ホスト | コンテナ | 用途 |
| --- | --- | --- |
| リポジトリルート | `/home/vscode/workspace` | ワークスペース |
| `~/.aws` | `/home/vscode/.aws` | AWS 認証情報 |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker ソケット（Docker in Docker） |

#### WSLg 音声を使う場合（オプション）

環境変数 `PULSE_SERVER` を設定することで、コンテナ内から WSLg の音声を利用できる（詳細は[WSLg 音声のセットアップ](#wslg-音声のセットアップwsl--wsl2-のみ)を参照）。

## 前提条件

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [VS Code](https://code.visualstudio.com/)
- [Dev Containers 拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## devcontainer での起動手順

1. `.env.example` をコピーして `.env` を作成する

    ```sh
    cp .devcontainer/.env.example .devcontainer/.env
    ```

2. `.env` の `COMPOSE_PROJECT_NAME` をプロジェクト名に変更する

    ```sh
    COMPOSE_PROJECT_NAME=myproject
    ```

3. VS Code でフォルダを開き、コマンドパレットから `Dev Containers: Reopen in Container` を実行する

## Linux 環境での起動手順

リポジトリをクローンし、以下を実行する。

```sh
sh .devcontainer/postCreateCommand.sh
```

## カスタマイズ

### Python / Node.js / Java のバージョン設定

`.devcontainer/.dotconfig/.scripts/config.sh` でインストール有無とバージョンを設定する。
バージョンを空にすると最新安定版がインストールされる。

```sh
# Python
INSTALL_PYTHON=true
INSTALL_PYTHON_VERSION=""   # 空で最新安定版 / 例: "3.12"

# Node.js
INSTALL_NODE=true
INSTALL_NODE_VERSION=""     # 空で最新安定版 / 例: "22"

# Java
INSTALL_JAVA=true
INSTALL_JAVA_VERSION=""     # 空で最新安定版 / 例: "21"

# Go
INSTALL_GO=false
INSTALL_GO_VERSION=""       # 空で最新安定版 / 例: "1.24.0"

# Rust
INSTALL_RUST=false
INSTALL_RUST_VERSION=""     # 空で stable / 例: "1.85.0"
```

### AI CLI ツールの有効・無効

`.devcontainer/.dotconfig/.scripts/config.sh` で設定する。

```sh
# AI CLI
INSTALL_CLAUDE_CODE=true
INSTALL_GEMINI_CLI=true
INSTALL_KIRO_CLI=true
```

### DB などのサービス追加

`.devcontainer/docker-compose.override.yml.example` を参考に `.devcontainer/docker-compose.override.yml` を作成してサービスを追加する。

```sh
cp .devcontainer/docker-compose.override.yml.example .devcontainer/docker-compose.override.yml
```

### WSLg 音声のセットアップ（WSL / WSL2 のみ）

Docker コンテナは WSLg の PulseAudio ソケットに直接アクセスできないため、Ubuntu WSL 上で PulseAudio を TCP で待ち受けさせ、コンテナから TCP 経由で接続する。

1. Ubuntu WSL 上でセットアップスクリプトを実行する

    ```sh
    sh .devcontainer/setup-wslg-audio.sh
    ```

    WSL を再起動しても自動で有効になるよう `~/.bashrc` に設定が追加される。

2. `docker-compose.wslg.yml.example` をコピーする

    ```sh
    cp .devcontainer/docker-compose.wslg.yml.example .devcontainer/docker-compose.wslg.yml
    ```

3. `devcontainer.json` の `dockerComposeFile` に追加する

    ```jsonc
    "dockerComposeFile": ["docker-compose.yml", "docker-compose.wslg.yml"]
    ```

4. コンテナをリビルドする

### VS Code 拡張機能の追加・変更

`.devcontainer/.dotconfig/.scripts/vscode_extension.txt` に拡張機能の ID を追記する。

## 注意事項

### リビルド後の最初のターミナルについて

コンテナのリビルド直後に自動で開くターミナルは、`postCreateCommand.sh` の実行完了前に起動するため、PATH が正しく設定されていない場合がある。

その場合は、そのターミナルを閉じて新しいターミナルを開く。

## 別プロジェクトへのコピー

このリポジトリをコピーして使う場合は `.devcontainer/.env` の `COMPOSE_PROJECT_NAME` を変更する。
設定しないと複数プロジェクト間でコンテナ名が衝突する場合がある。
