{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "sir-launchalot";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/PieOrCake/sir_launchalot/releases/download/v${version}/Sir_Launchalot-${version}-x86_64.AppImage";
    hash = "sha256-353uO7SCyx4fPTLeKU4s0x1M4FSMjItTts/5ty9k/s8=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/sir-launchalot.desktop -t $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = {
    description = "Multibox launcher for Guild Wars 2";
    homepage = "https://github.com/PieOrCake/sir_launchalot";
    license = lib.licenses.gpl3Only;
    mainProgram = "sir-launchalot";
    platforms = [ "x86_64-linux" ];
  };
}
