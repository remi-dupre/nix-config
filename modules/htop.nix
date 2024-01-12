{ config, pkgs, lib, inputs, ... }:

{
  programs.htop = {
    enable = true;

    settings = with config.lib.htop; {
      color_scheme = 6;
      hide_kernel_threads = 1;
      hide_userland_threads = 1;
      highlight_threads = 1;
      shadow_other_users = 1;
      show_program_path = 0;
      sort_direction = -1;
      sort_key = fields.PERCENT_CPU;
      tree_sort_direction = -1;
      tree_sort_key = fields.PERCENT_CPU;
      all_branches_collapsed = 1;

      fields = with fields; [
        PID
        USER
        NICE
        STATE
        PERCENT_CPU
        PERCENT_MEM
        M_RESIDENT
        IO_RATE
        TIME
        COMM
      ];
    } // (
      with config.lib.htop;
      leftMeters [
        (text "Tasks")
        (text "LoadAverage")
        (graph "CPU")
      ]
    ) // (
      with config.lib.htop;
      rightMeters [
        (bar "Memory")
        (bar "Swap")
        (text "Blank")
        (text "DiskIO")
        (text "NetworkIO")
        (text "Battery")
      ]
    );
  };
}
