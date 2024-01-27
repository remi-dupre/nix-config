{ lib, pkgs, ... }:

{
  programs = {
    fish = {
      enable = true;

      plugins = [
        { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      ];

      shellInit = ''
        # Fix conflict between fzf default script and fzf.fish plugin
        # See https://haseebmajid.dev/posts/2023-09-19-til-how-to-use-fzf-fish-history-search/#appendix
        bind \cr _fzf_search_history
        bind -M insert \cr _fzf_search_history
      '';
    };

    fzf = {
      enable = true;
      enableBashIntegration = false; # Managed by fish plugin
      enableFishIntegration = false; # Managed by fish plugin
      enableZshIntegration = false; # Managed by fish plugin
    };

    starship = {
      enable = true;

      settings = {
        fill.symbol = " ";
        package.disabled = true;
        directory.style = "bold underline cyan";
        username.format = "[$user](dimmed yellow)@";

        format = lib.concatStrings [
          "$all$fill$kubernetes"
          "$line_break"
          "$jobs$battery$time$status$container$shell$character"
        ];

        hostname = {
          format = "[$hostname]($style) ";
          style = "dimmed";
          ssh_only = false;
        };

        time = {
          disabled = false;
          format = "[$time]($style) ";
          style = "dimmed";
        };

        custom.nice = {
          command = ''echo "★ $(nice)"'';
          when = ''if [ $(nice) == "0" ]; then exit 1; else exit 0; fi'';
          shell = "${pkgs.bash}/bin/bash";
        };
      };
    };
  };
}
