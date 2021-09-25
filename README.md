# ubuntu-lxde-msxdev

ubuntu20.04ベースのMSX開発環境です。以下のものが含まれています。

* lxde + 日本語入力 fcitx
* Visual Source Code
* z88dk (z80向け開発ツール)
* openMSX / openMSX debugger
* MAME + c-bios ドライバ
* nMSXtiles (MSX向けパターンエディタ)
* multipaint (レトロPCフォーマット対応のドローツール)

## lxde + 日本語入力 fcitx

GUI環境．
メニューのプログラミングのジャンルに一通りのMSX関連のアプリを追加してあります．
Ctrl+Space で日本語入力切り替えができます．

## Visual Source Code

Terminalから ```code``` で起動します．
オプションで ```--no-sandbox``` を追加しないと起動しないので alias で設定してあります．

現状 root で起動させるには，以下の手順が必要．
/root に /home/msx の .Xauthority をコピーしておく
```
$ sudo su
$ cp /home/msx/.Xauthority /root
$ exit
```

以下で起動する
```
$ sudo code --user-data-dir="/root" --no-sandbox
```

pulseaudio 
```
$ pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
```

