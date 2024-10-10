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
      key = "4762C65BF8D86A3365C1D10A461302CD12494653";
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
