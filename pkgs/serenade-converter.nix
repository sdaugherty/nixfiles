{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "serenade-converter";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/PieOrCake/serenade-converter/releases/download/v${version}/Serenade_Music_Converter-x86_64.AppImage";
    hash = "sha256-f+h6BFgGM+N3vxKDfgXlt4hSe98tg80bpgIIrukdknY=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/serenade-midi-converter.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/serenade-midi-converter.desktop \
      --replace-fail 'Exec=serenade-midi-converter' 'Exec=serenade-converter'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = {
    description = "Convert MIDI files to MusicXML and AutoHotkey scripts for Guild Wars 2 in-game instruments";
    homepage = "https://github.com/PieOrCake/serenade-converter";
    license = lib.licenses.gpl3Only;
    mainProgram = "serenade-converter";
    platforms = [ "x86_64-linux" ];
  };
}
