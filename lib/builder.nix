pkgs: presentation: let
  generateMarkdown = import ./generator.nix pkgs;
in
  pkgs.runCommand
  "${presentation.title}.html"
  {
    MARP = "${pkgs.marp-cli}/bin/marp";
    CONTENT = generateMarkdown presentation;
    HLJS_THEME = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/highlightjs/highlight.js/1711895d7b8824ac96a66bb7bf6d3af17fc52f19/src/styles/base16/twilight.css";
      hash = "sha256-x08ZBUeWojxvbrZXp1j3Adxl1iGufQFBZ1nJOd5RhBs=";
    };
    NUMBER_ICONS = builtins.genList (x:
      pkgs.fetchurl {
        url = "https://icongr.am/material/numeric-${toString (x + 1)}-circle.svg?color=666666";
        hash =
          builtins.elemAt [
            "sha256-HLbXiixddCV/vpd3Dt3TyPxjIEpsryHneCvHyltNsOQ="
            "sha256-pYm9Hih9vzaVEc0KR2J2Tkm+WW+WCnBbbaMYr39uUWs="
            "sha256-E2kVJoRSP63/yAuxmW7KQ1z+vca2+coEX/JO1PSbvQU="
            "sha256-L03ooeHJzzKWsWgOxhYOSKdu15JB5NgDSjnBbMe8CkY="
            "sha256-k9jrPFDqHEo3gPqoRU1OuUfkofzL95pxCLhEjHUz8FQ="
            "sha256-pCbiH1Cd1sTDlhj4Y0/wv6QUg4yfl9DcN4oNH8jim6c="
            "sha256-GIqnDt3kd5xlyGAF4mBwZpuqhtvoGtUlnWsJ8DP50Z8="
            "sha256-z1MLDrIMkzQ8AKlUnKzLSN4vdMPjsnRKj8+u8K4mTWQ="
            "sha256-iTfiKCVAMmeZQvXIHj2Yd4wAj64YeiBoIUeyZAxfKoo="
            "sha256-JinoWvJrrltr4DYLuqYtBbHUYBVicV2MQVutsk3FJGA="
          ]
          x;
      })
    10;
    ASSETS = presentation.assets;
  }
  ''
    mkdir -p $out/assets

    i=1
    for p in $NUMBER_ICONS; do
      cp $p $out/assets/$i.svg
      i=$((i+1))
    done

    for p in $ASSETS; do
      outp=$(basename "$p" | cut -c34-)
      cp $p $out/assets/$outp
    done

    echo "$CONTENT" > $out/index.md
    cp "$HLJS_THEME" $out/code-theme.css
    echo "$CONTENT" | "$MARP" --html > $out/index.html
  ''
