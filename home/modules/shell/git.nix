{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Rémi Dupré";
    userEmail = "remi@dupre.io";

    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers decorations";
        whitespace-error-style = "22 reverse";
      };
    };

    signing = {
      signByDefault = true;
      key = "9A55335D0A120F1C1B1183237E40AB46381379CE";
    };

    extraConfig = {
      branch.sort = "-committerdate";
      column.ui = "auto";
      commit.verbose = true;
      diff.algorithm = "histogram";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      rebase.autostash = true;

      # Fix a weird issue for the Gitlab instance of eUL. See
      # https://stackoverflow.com/a/69891948
      http.postBuffer = 157286400; # 150 MB

      rerere = {
        enabled = true;
        autoUpdate = true;
      };
    };
  };
}
