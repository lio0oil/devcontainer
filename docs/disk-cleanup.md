# Rancher Desktop のディスク容量を調査して減らす手順

Rancher Desktop + WSL2 + Dev Container の環境で、ディスク容量（`ext4.vhdx`）が膨らんだときに、原因を調べて減らすための手順。
実際に 73.6GB まで膨らんだ環境で行った作業をまとめている。

VS Code で接続したまま行える、日常のお手入れ（定期メンテナンス）は [disk-maintenance.md](disk-maintenance.md) を参照。

## この手順で分かること

- `ext4.vhdx`（WSL の仮想ディスク）の場所
- どのデータ（イメージ・コンテナ・ボリューム）が容量を使っているか
- 削除してよいものと、削除の手順
- 削除したあとに、Windows のディスクを実際に空ける方法

## 用語の説明

| 用語 | 説明 |
| --- | --- |
| `ext4.vhdx` | WSL2 のディストリビューション 1 つにつき 1 つある、仮想ディスクのファイル。Linux 側のデータは全部この中に入る |
| ボリューム | Docker が管理する、コンテナの外に置くデータ置き場。コンテナを消しても残る |
| 書き込み層 | コンテナの中で作成・変更したファイルが溜まる場所。コンテナを消すと一緒に消える |
| コンパクト（compact） | vhdx の中の空き領域を取り除いて、ファイルサイズを小さくする作業 |

## 重要な前提

- vhdx は、中のデータが増えるとファイルも大きくなるが、中のデータを消しても **自動では小さくならない**。ディスクを実際に空けるには、最後にコンパクトが必要。
- Rancher Desktop の Docker のデータは、`rancher-desktop-data` という WSL ディストリビューションの vhdx に入っている。
- このリポジトリの `workspace` ボリュームには、開発中の作業ファイルが入っている。**削除対象にしない。**

## 手順 0: vhdx の場所を確認する

PowerShell で、WSL のディストリビューション名と vhdx の場所を一覧にする。

```powershell
Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss' | ForEach-Object {
  $p = Get-ItemProperty $_.PSPath
  $base = $p.BasePath -replace '^\\\\\?\\',''
  $vhd = if ($p.VhdFileName) { $p.VhdFileName } else { 'ext4.vhdx' }
  $full = Join-Path $base $vhd
  [pscustomobject]@{ Name=$p.DistributionName; Path=$full; SizeGB=[math]::Round((Get-Item $full).Length/1GB,2) }
} | Format-List
```

Rancher Desktop の Docker データは、通常は次の場所にある。

```text
%LOCALAPPDATA%\rancher-desktop\distro-data\ext4.vhdx
```

## 手順 1: 何が容量を使っているか調べる

Rancher Desktop を起動した状態で、Docker の使用量を見る。

```powershell
docker system df
```

ボリュームごとのサイズを見る。

```powershell
docker system df -v
```

コンテナごとのサイズを見る。`SIZE` が書き込み層のサイズ。

```powershell
docker ps -a --size
```

## 手順 2: 大きいものの中身を調べる（読み取り専用）

ここからの `du` は読み取りだけで、データは変更されない。ただし、ファイル数が多いと数十分かかることがある。

### ボリュームの中身

ボリュームの実体は、Rancher Desktop の WSL ディストリビューション内の `/var/lib/docker/volumes/<ボリューム名>/_data` にある。

```powershell
wsl -d rancher-desktop -u root -e sh -c "du -k -d 4 /var/lib/docker/volumes/<ボリューム名>/_data | sort -rn | head -40"
```

### コンテナの書き込み層

この環境では、containerd のスナップショット方式が使われていて、`docker inspect` では書き込み層の場所が分からない。
スナップショットは次の場所に番号付きで並んでいる。

```text
/var/lib/docker/containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/<番号>
```

まず、各スナップショットのサイズを出して、飛び抜けて大きい番号を探す。

```powershell
wsl -d rancher-desktop -u root -e sh -c "du -sk /var/lib/docker/containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/*"
```

大きい番号が見つかったら、その中身をディレクトリ別に集計する。コンテナのファイルは、その番号の下の `fs` に入っている。

```powershell
wsl -d rancher-desktop -u root -e sh -c "du -k -d 4 /var/lib/docker/containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/<番号>/fs | sort -rn | head -40"
```

### 調査での注意点

- **`$` を含む変数をコマンドに入れない。** `wsl.exe` を経由すると `$S` のような変数が空になり、`du` が `/` 全体（Windows の C: ドライブを含む）を調べ始める。結果が使えない数値になり、時間も大きく無駄になる。パスは直接書く。
- `rancher-desktop-data` ディストリビューションには `ls` や `sort` などが入っていない。調査コマンドは `rancher-desktop` ディストリビューションで実行する。
- `docker diff` は、変更ファイルが多いと終わらない。使わない。
- 時間がかかるコマンドは、バックグラウンドで実行する。

## 手順 3: 削除してよいものを判断する

今回の環境で、削除してよいと判断したものは次のとおり。いずれも、あとから自動的に作り直される。

| 対象 | 場所 | 今回のサイズ | 原因 |
| --- | --- | --- | --- |
| 古い VS Code サーバー | `vscode` ボリュームの `vscode-server/bin/linux-x64/<コミットID>` | 約 18GiB | VS Code の更新のたびに新しいバージョンが追加され、古いものが消えない |
| 拡張機能キャッシュ | `vscode` ボリュームの `vscode-server/extensionsCache` | 約 11GiB | 拡張機能のダウンロードキャッシュが溜まる |
| uv のキャッシュ | コンテナ内の `~/.cache/uv` | 約 13GiB | Python パッケージのインストールのたびにキャッシュが増える |

削除しないもの:

- `workspace` ボリューム（作業ファイルが入っている）
- コンテナ本体と、`postCreateCommand` で入れたツール（Homebrew、Java、Rust など）
- `~/.cache/aws`、`~/.terraform.d`、`~/.ivy2`（各 1GiB 前後。効果が小さく、確認が必要）

## 手順 4: 削除する

### 4-1. VS Code を閉じる

このコンテナに接続している VS Code のウィンドウを、すべて閉じる。

`vscode` ボリュームは、Dev Containers を使うすべてのコンテナで共有される。他の devcontainer を使っている場合は、その VS Code も閉じる。

### 4-2. 古い VS Code サーバーを削除する

先に、新しい順の一覧を確認する。先頭の 2 個が残す対象。フォルダ以外のファイルが混ざっていないかも確認する。

```powershell
wsl -d rancher-desktop -u root -e sh -c "ls -1dt /var/lib/docker/volumes/vscode/_data/vscode-server/bin/linux-x64/*"
```

問題なければ、3 個目以降を削除する。

```powershell
wsl -d rancher-desktop -u root -e sh -c "ls -1dt /var/lib/docker/volumes/vscode/_data/vscode-server/bin/linux-x64/* | tail -n +3 | xargs rm -rf"
```

### 4-3. 拡張機能キャッシュを削除する

```powershell
wsl -d rancher-desktop -u root -e sh -c "rm -rf /var/lib/docker/volumes/vscode/_data/vscode-server/extensionsCache/*"
```

### 4-4. uv のキャッシュを削除する

コンテナを一時的に起動する。`<プロジェクト名>` は `.devcontainer/.env` の `COMPOSE_PROJECT_NAME` の値。

```powershell
docker start <プロジェクト名>-devcontainer-1
```

uv は Homebrew でインストールしているので、パスを指定して実行する。

```powershell
docker exec -u vscode <プロジェクト名>-devcontainer-1 /home/linuxbrew/.linuxbrew/bin/uv cache clean
```

コンテナを止める。

```powershell
docker stop <プロジェクト名>-devcontainer-1
```

> `Exited (137)` と表示されるのは異常ではない。コンテナが `sleep infinity` で動いていて、停止の合図を受け付けないため、最後に強制終了されるから。
>
> uv は「30GiB 削除した」と表示することがある。これは同じファイルを複数回数えているためで、実際に減るのは `du` で見たサイズ（今回は約 13GiB）。

## 手順 5: vhdx をコンパクトして Windows のディスクを空ける

ここまでの削除では、vhdx のファイルサイズはまだ変わらない。次の手順で小さくする。

1. Rancher Desktop を完全に終了する（タスクトレイのアイコンから Quit）。
2. **管理者権限の PowerShell** を開き、WSL を止める。

```powershell
wsl --shutdown
```

3. 次のどちらかでコンパクトする。

Hyper-V が使える環境なら、1 行で済む。

```powershell
Optimize-VHD -Path "$env:LOCALAPPDATA\rancher-desktop\distro-data\ext4.vhdx" -Mode Full
```

`Optimize-VHD` が使えない場合は、`diskpart` を使う。以下を 1 行ずつ入力する。

```text
diskpart
select vdisk file="C:\Users\<ユーザー名>\AppData\Local\rancher-desktop\distro-data\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```

4. コンパクトの作業中は、C: に少し空き容量が必要。事前に空きを確認する。
5. 終わったら、Rancher Desktop を起動する。

## 実施結果（2026-10-16）

| 対象 | 削除前 | 削除後 |
| --- | --- | --- |
| `vscode` ボリューム | 約 29GiB | 約 1.3GiB |
| コンテナの書き込み層 | 約 28GiB | 約 14.7GiB |
| `rancher-desktop-data` の vhdx | 73.6GB | コンパクト後に記入 |

## 原因と再発防止

原因は、キャッシュが掃除されないまま溜まり続けたことと、vhdx が自動では縮まないこと。

| 対策 | 内容 |
| --- | --- |
| VS Code サーバーの整理 | 数か月に一度、手順 4-2 と 4-3 を行う |
| uv のキャッシュの整理 | 時々、コンテナ内で `uv cache prune` を実行する |
| 定期的な確認 | `docker system df` でサイズを確認する |
| ディスクを空ける | 削除したあとは、手順 5 のコンパクトを行う |
