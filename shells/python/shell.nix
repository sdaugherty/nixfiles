{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Latest stable Python
    python3
    
    # Python tools
    uv
    poetry
    pipx
    
    # Gemini CLI
    gemini-cli
  ];

  shellHook = ''
    echo "Python development environment"
    echo "Python version: $(python3 --version)"
    echo "Included tools: gemini-cli, uv, poetry, pip, pipx"
  '';
}
