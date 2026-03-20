# BACKLOG

- [ ] **setup.ps1: symlink 作成時の非終了エラーを適切にハンドリング**
  - `New-Item -ItemType SymbolicLink` が "Administrator privilege required" をエラーストリームに書き込むが例外を throw しないため、try/catch でキャッチできない
  - `-ErrorAction Stop` を追加して終了エラーに変換するか、`$Error` をチェックして後処理する方法を検討
  - 参照: setup.ps1 `New-DotfilesLink` 関数 L71-81
