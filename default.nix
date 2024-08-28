let
  pkgs = import <nixpkgs> {};
  presentation = {
    title = "Nix/NixOS Seminar";
    titleImage = "./assets/nix-logo.svg";
    description = "What is it and why is it useful?";
    authors = ["Cole Stowell"];
    theme = "gaia";
    assets = [
      ./images/presentation_repo.png
      (pkgs.fetchurl
        {
          url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/56b7a5788005a3eaecb5298f0dbed0f7d1573abc/logo/nix-snowflake-colours.svg";
          hash = "sha256-43taHBHoFJbp1GrwSQiVGtprq6pBbWcKquSTTM6RLrI=";
          name = "nix-logo.svg";
        })
    ];
    slides = [
      {
        type = "basic";
        title = "A Little About Me";
        body = ''
          My name is Cole (he/him).

          I'm a 2nd year CS major.

          I love Linux, Rust, and NIX.
        '';
      }
      {
        type = "basic";
        title = "Save questions to the end";
        body = ''
          I am horribly distractable and might trail off in this presentation.
        '';
      }
      {
        type = "numbered";
        title = "'Nix' refers to many things!";
        slideGroups = [
          {
            title = "Nix Language";
            slides = [
              {
                type = "basic";
                title = "Data Types";
                body = ''
                  ```nix
                  10           # Numbers
                  "hello!"     # Strings
                  [ 10 20 50 ] # Lists

                  # Attribute Sets
                  {
                    hello = "world";
                    foo = "bar";
                    num = 20;
                  }
                  ```
                '';
              }
              {
                type = "columns";
                title = "Nix Expressions";
                bodies = [
                  ''
                    - Returns a value (number, string, list, attribute set, etc.)
                    - Are files
                      - No main function, just "building a value"
                  ''
                  ''
                    ```nix
                    # authors.nix
                    ["Eddie" "Wilson"]
                    ```

                    ```nix
                    # default.nix
                    let
                      authors = import ./authors.nix;
                    in
                      "By ''${builtins.concatStringsSep " and " authors}"
                    #  By Eddie and Wilson
                    ```
                  ''
                ];
              }
              {
                type = "columns";
                title = "Nix is a *Functional* Language";
                bodies = [
                  ''
                    - "Turn a thing into a different thing"
                    - Single parameter (but we can curry functions together)
                  ''
                  ''
                    ```nix
                    let
                      add = s: t: s + t;
                    in
                      add 10 20
                    ```

                    ```nix
                    multiplier:
                      builtins.map (x: x * multiplier) [1 3 4 7 20]
                    ```
                  ''
                ];
              }
            ];
          }
          {
            title = "Nix Package Manager";
            slides = [
              {
                type = "basic";
                title = "Nix can be installed almost everywhere!";
                body = ''
                  - Linux
                  - MacOS
                  - Windows WSL
                  - Docker
                  - And (with some added work) even more!
                '';
              }
              {
                type = "basic";
                title = "Nix is not a traditional package manager";
                body = ''
                  - Packages are called **derivations**.
                  - Created via evaluating nix expressions
                  - Can be installed in many ways so not really important
                '';
              }
              {
                type = "basic";
                title = "What is it made of?";
                body = ''
                  The most important parts are the
                  - Input paths (Folders, files, **other derivations**, etc.)
                  - Builder script (with some arguments)

                  An **out path** is *automatically* generated based on the inputs and builder script.
                '';
              }
              {
                type = "basic";
                title = "Where does this all take place?";
                body = ''
                  - THE NIX STORE!
                  - Exists at /nix/store
                  - Contains just about everything (compiled software, source code, images, libraries, etc.)
                  - Paths look like...
                    <span class='small'>
                    - `${pkgs.firefox}`
                    - `${pkgs.bash}`
                    - `${./images/nix_language_basics.png}`
                    </span>
                '';
              }
              {
                type = "basic";
                title = "How is a derivation built? (1/2)";
                body = ''
                  1) Nix Expression is evaluated and it returns a derivation
                  2) Derivation is **instantiated** (.drv file is created in the Nix Store)
                '';
              }
              {
                type = "basic";
                title = "How is a derivation built? (2/2)";
                body = ''
                  After instantiation, we now have to **realize** the derivation...
                  1) Before realizing the target derivation, we realize all derivations depended on
                  2) Then the builder is run with the fully realized inputs and writes to output path
                '';
              }
              {
                type = "basic";
                title = "";
                body = ''
                  - **Anybody** can build **anything** and get the **exact same result, bit-for-bit**
                    - When inputs change like...
                      - Source code
                      - Compiler
                      - Library
                      - Builder script
                    - Considered a brand new derivation
                      - Upgrading **cannot** break other software
                '';
              }
            ];
          }
          {
            title = "Nixpkgs";
            slides = [
              {
                type = "basic";
                title = "What the hell is Nixpkgs?";
                body = ''
                  - A massive nix expression containing 100,000+ derivations!
                    - Technically a function which returns a **massive** attribute set
                  - Contains some useful functions too
                '';
              }
              {
                type = "columns";
                title = "We can use Nixpkgs!";
                bodies = [
                  ''
                    `<nixpkgs>` evaluates to the path of the current version in the nix store

                    Mine is `${<nixpkgs>}`
                  ''
                  ''
                    ```nix
                    let
                      pkgs = import <nixpkgs> { };
                    in
                      pkgs.firefox
                    ```
                  ''
                ];
              }
            ];
          }
          {
            title = "NixOS";
            slides = [
              {
                type = "basic";
                title = "What is it?";
                body = ''
                  > What if an **operating system** was the output *instead* of a derivation?

                  - Define all software, services, configurations, drivers, bootloader, etc.
                  - **Super** maintainable
                '';
              }
              {
                type = "basic";
                title = "NixOS can do so much...";
                center = true;
                body = "";
              }
              {
                type = "columns";
                title = "Easily Configure Services";
                bodies = [
                  ''
                    Example: CalDAV server on the domain "cal.example.domain" with an automatically generated verified SSL certificate
                  ''
                  ''
                    ```nix
                    services = {
                      radicale = {
                        enable = true;
                        settings.server.hosts = ["127.0.0.1:5232"];
                      };
                      nginx.virtualHosts = {
                        "cal.example.domain" = {
                          forceSSL = true;   # Redirect to https
                          enableACME = true; # Request SSL cert
                          locations."/" = {
                            recommendedProxySettings = true;
                            proxyPass = "http://localhost:5232/";
                          };
                        };
                      };
                    };
                    ```
                    *Only 16 lines!*
                  ''
                ];
              }
              {
                type = "basic";
                title = "Rollbacks";
                body = ''
                  - Everytime you "build" your NixOS config, a new generation is created
                  - Switch between generations at runtime **and** boot time

                  *Shaun Thornton is the 🐐*
                '';
              }
              {
                type = "basic";
                title = "Impermanence";
                body = ''
                  NixOS can be set up to not retain any files you don't *explicitly* list

                  *I only keep what I want!*
                '';
              }
              {
                type = "basic";
                title = "Ecosystem Stuff";
                body = ''
                  - **home-manager**: Configure individual users
                  - **nixos-anywhere**: Overwrite *any* Linux system with your NixOS config
                  - **deploy-rs**: Deploy your config to a machine easily
                  - **sops-nix**: Store secrets and decrypt at runtime
                  - **nixos-generators**: Generate bootable image from NixOS config
                  - Any literally so much more!
                '';
              }
            ];
          }
        ];
      }
      {
        type = "basic";
        title = "Nix is so powerful!";
        center = true;
        body = ''
          It can build so much reproducibly...
        '';
      }
      {
        type = "basic";
        title = "...even a presentation on Nix!";
        body = ''
          ![presentation repo](./assets/presentation_repo.png)
        '';
      }
      {
        type = "basic";
        title = "Thank you for listening!!";
        titleImage = "./assets/nix-logo.svg";
        body = "Any questions?";
        center = true;
      }
    ];
  };
  buildPresentation = import ./lib/builder.nix pkgs;
in
  buildPresentation presentation
