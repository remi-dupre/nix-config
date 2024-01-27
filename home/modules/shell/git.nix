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
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };
}
