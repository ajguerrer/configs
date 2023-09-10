{ lib, stdenvNoCC, fetchFromGitHub, gtk3, jdupes, hicolor-icon-theme }:

stdenvNoCC.mkDerivation rec {
  pname = "tela-icon-theme";
  version = "59a8efd4ba267be7597a80035049f99351235465";

  src = fetchFromGitHub {
    owner = "ajguerrer";
    repo = "Tela-icon-theme";
    rev = version;
    hash = "sha256-xW9h661AdWVf5xuU0A+TDRiQ5/u9D+LBnd46MV45vF8=";
  };

  nativeBuildInputs = [ gtk3 jdupes ];

  propagatedBuildInputs = [ hicolor-icon-theme ];

  dontDropIconThemeCache = true;

  # These fixup steps are slow and unnecessary.
  dontPatchELF = true;
  dontRewriteSymlinks = true;

  installPhase = ''
    runHook preInstall

    patchShebangs install.sh
    mkdir -p $out/share/icons
    ./install.sh -a -d $out/share/icons
    jdupes -l -r $out/share/icons

    runHook postInstall
  '';

  meta = with lib; {
    description = "A flat colorful Design icon theme";
    homepage = "https://github.com/ajguerrer/Tela-icon-theme";
    changelog = "https://github.com/ajguerrer/Tela-icon-theme/releases/tag/${src.rev}";
    license = licenses.gpl3Only;
    # darwin systems use case-insensitive filesystems that cause hash mismatches
    platforms = subtractLists platforms.darwin platforms.unix;
    maintainers = with maintainers; [ figsoda ];
  };
}