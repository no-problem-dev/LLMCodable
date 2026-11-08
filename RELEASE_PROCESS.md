# リリースプロセス

CI もリリース用のスクリプトも無い。版は手で決めて、タグを push するだけ。

1. ローカルで `swift build --build-tests` と `swift test` が通ることを確かめる
2. `CHANGELOG.md` の `## [Unreleased]` を `## [x.y.z] - YYYY-MM-DD` に直し、`main` に入れる
3. その merge のコミットにタグを付けて push する

   ```bash
   git tag vx.y.z && git push origin vx.y.z
   ```

版は [SemVer](https://semver.org) に従う。タグはこれまでと同じく `v` を付ける（`v1.0.1`）。
