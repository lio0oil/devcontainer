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

| ホスト | コンテナ内パス | 用途 |
| --- | --- | --- |
| 名前付きボリューム `workspace` | `/home/vscode/workspace` | VS Code のワークスペース。ここで開発作業を行う。コンテナを削除・リビルドしてもデータが保持される |
| リポジトリルート | `/home/vscode/host` | このリポジトリ自体をマウント。`.devcontainer/` 以下のスクリプトはここ経由で実行される |
| `~/.aws` | `/home/vscode/.aws` | ホストの AWS 認証情報を共有（`~/.aws/credentials` など） |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker ソケット（Docker in Docker） |

> **名前付きボリュームへの Windows からのアクセス**
> エクスプローラーで `\\wsl.localhost\rancher-desktop-data\docker\volumes\` を開くと名前付きボリュームの実体にアクセスできる。
> ボリューム名は `<COMPOSE_PROJECT_NAME>_workspace` となる（例: `myproject_workspace`）。
>
> **注意事項:**
> - Rancher Desktop が起動していないとこのパスにアクセスできない
> - エクスプローラーから直接ファイルを編集・削除するとデータが壊れる可能性があるため、参照・バックアップ用途にとどめること

### コンテナ内のディレクトリ構成

```
/home/vscode/
├── workspace/   ← 開発作業用ディレクトリ（VS Code がここを開く）
├── host/        ← このリポジトリのルート（リードオンリーではない）
│   └── .devcontainer/
│       ├── devcontainer.json
│       ├── docker-compose.yml
│       └── postCreateCommand.sh  ← コンテナ作成時に実行される初期化スクリプト
└── .aws/        ← AWS 認証情報（ホストと共有）
```

#### WSLg 音声を使う場合（オプション）

環境変数 `PULSE_SERVER` を設定することで、コンテナ内から WSLg の音声を利用できる（詳細は[WSLg 音声のセットアップ](#wslg-音声のセットアップwsl--wsl2-のみ)を参照）。

## 前提条件

- [Rancher Desktop](https://rancherdesktop.io/)
  - Container Engine: `dockerd (moby)` を選択する
  - WSL Integration: 使用する WSL2 ディストリビューションを有効にする
- [VS Code](https://code.visualstudio.com/)
  - [Dev Containers 拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## WSL2 の初期セットアップ（初回のみ）

WSL2 をインストールした直後はデフォルトユーザーが未設定で root として起動する。
一般ユーザーを作成してデフォルトに設定する。

### 1. 一般ユーザーを作成する

WSL2 のターミナル（root）で実行する。

```sh
# ユーザーを作成（名前は任意）
useradd -m -s /bin/bash <ユーザー名>
passwd <ユーザー名>

# sudo を使えるようにする
usermod -aG sudo <ユーザー名>
```

### 2. デフォルトユーザーを設定する

```sh
cat << 'EOF' > /etc/wsl.conf
[user]
default=<ユーザー名>
EOF
```

### 3. WSL2 を再起動する

Windows の PowerShell で実行する。

```powershell
wsl --shutdown
wsl
```

再起動後、`whoami` で作成したユーザー名が表示されれば完了。

## devcontainer での起動手順

### 1. `.env` を作成する

```sh
cp .devcontainer/.env.example .devcontainer/.env
```

`.env` の `COMPOSE_PROJECT_NAME` をプロジェクト名に変更する。

```sh
COMPOSE_PROJECT_NAME=myproject
```

### 2. Dev Container を起動する

VS Code でプロジェクトフォルダを開き、コマンドパレット（`Ctrl+Shift+P`）から `Dev Containers: Reopen in Container` を実行する。

`postCreateCommand`（環境構築）と `postAttachCommand`（VS Code 拡張機能インストール）が自動で実行される。

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

#### Dev Container で使う場合（Windows からコンテナを起動）

コンテナは `host.docker.internal:4713` 経由で WSL2 の PulseAudio に TCP 接続する。

1. WSL2 側で PulseAudio TCP を有効化する（初回のみ）

    Claude Code をインストールした WSL2 ディストリビューション上で実行する。

    ```sh
    sh .devcontainer/setup-wsl-pulse-tcp.sh
    ```

2. `docker-compose.wslg.yml.example` をコピーする

    ```sh
    cp .devcontainer/docker-compose.wslg.yml.example .devcontainer/docker-compose.wslg.yml
    ```

3. `devcontainer.json` の `dockerComposeFile` に追加する

    ```jsonc
    "dockerComposeFile": ["docker-compose.yml", "docker-compose.wslg.yml"]
    ```

4. コンテナをリビルドする

#### WSL2 上で直接使う場合

WSLg はすでに PulseAudio を提供しているため TCP 設定は不要。ALSA が PulseAudio を使うよう設定する。

Claude Code をインストールした WSL2 ディストリビューション上で実行する。

```sh
sh .devcontainer/setup-wsl-alsa.sh
```

### VS Code 拡張機能の追加・変更

`.devcontainer/.dotconfig/.scripts/vscode_extension.txt` に拡張機能の ID を追記する。

## 注意事項

### リビルド後の最初のターミナルについて

コンテナのリビルド直後に自動で開くターミナルは、`postCreateCommand.sh` の実行完了前に起動するため、PATH が正しく設定されていない場合がある。

その場合は、そのターミナルを閉じて新しいターミナルを開く。

## 別プロジェクトへのコピー

このリポジトリをコピーして使う場合は `.devcontainer/.env` の `COMPOSE_PROJECT_NAME` を変更する。
設定しないと複数プロジェクト間でコンテナ名が衝突する場合がある。
