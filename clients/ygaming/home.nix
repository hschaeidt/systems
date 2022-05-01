{pkgs, ...}:
{
    imports = [];

    home.packages = with pkgs; [
        wget
        firefox
    ];

    programs.vim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
        vim-nix
        ];
        settings = {
        ignorecase = true;
        smartcase = true;
        number = true;
        relativenumber = true;
        };
    };

    programs.git = {
        enable = true;
        userName = "Hendrik Schaeidt";
        userEmail = "he.schaeidt@gmail.com";
        extraConfig = {
        credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe";
        core.editor = "vim";
        };
    };
}