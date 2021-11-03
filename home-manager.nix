{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.maycommit = {
    nixpkgs.config.allowUnfree = true;
    programs = {
      fish = {
        enable = true;
        functions = {
          __fish_command_not_found_handler = {
            body = "__fish_default_command_not_found_handler $argv[1]";
            onEvent = "fish_command_not_found";
          };

          fish_prompt = ''
            set -l last_pipestatus $pipestatus
            set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
            set -l normal (set_color normal)

            # Color the prompt differently when we're root
            set -l color_cwd $fish_color_cwd
            set -l suffix '>'
            if functions -q fish_is_root_user; and fish_is_root_user
                if set -q fish_color_cwd_root
                    set color_cwd $fish_color_cwd_root
                end
                set suffix '#'
            end

            # If we're running via SSH, change the host color.
            set -l color_host $fish_color_host
            if set -q SSH_TTY
                set color_host $fish_color_host_remote
            end

            # Write pipestatus
            # If the status was carried over (e.g. after `set`), don't bold it.
            set -l bold_flag --bold
            set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
            if test $__fish_prompt_status_generation = $status_generation
                set bold_flag
            end
            set __fish_prompt_status_generation $status_generation
            set -l prompt_status (__fish_print_pipestatus "[" "]" "|" (set_color $fish_color_status) (set_color $bold_flag $fish_color_status) $last_pipestatus)
            
            set -l nix_shell_info (
              if test -n "$IN_NIX_SHELL"
                echo -n "[nix-shell] "
              end
            )

            echo -n -s "$nix_shell_info" (set_color $fish_color_user) "$USER" $normal @ (set_color $color_host) (prompt_hostname) $normal ' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
          '';
        };
      };
      git = {
        enable = true;
        userName  = "Maycon Pacheco";
        userEmail = "mayconjrpacheco@gmail.com";
	      signing = {
          key= "46944C7569A20AA4";
        };
      };
      vscode = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          dbaeumer.vscode-eslint
          vscodevim.vim
          esbenp.prettier-vscode
          golang.Go
        ];
        userSettings = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
          "window.zoomLevel" = true;
        };
      };
      gpg = {
        enable = true;
      };
    };
    services = {
      gpg-agent = {
        enable = true;
        extraConfig = ''
          allow-loopback-pinentry
          default-cache-ttl 7200
        '';
      };
    };
  };
}
