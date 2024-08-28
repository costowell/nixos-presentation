pkgs: {
  theme ? "default",
  title ? "Presentation",
  titleImage ? "",
  description ? "",
  authors ? [],
  slides ? [],
  assets ? [],
}: let
  inherit (pkgs) lib;

  style =
    lib.strings.concatLines (builtins.genList (x: ''
        img[alt="${toString (x + 1)}"] {
          view-transition-name: a${toString (x + 1)};
          contain: layout;
        }
      '')
      10)
    + ''
      img:is(${builtins.concatStringsSep ", " (builtins.genList (x: ''[alt="${toString (x + 1)}"]'') 10)}) {
        height: 64px;
        width: 64px;
        position: relative;
        top: -0.1em;
        vertical-align: middle;
      }

      :root {
        --color-background: #fff;
        --color-foreground: #333;
        --color-highlight: #f96;
        --color-dimmed: #888;
      }

      .columns {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 1rem;
      }
      .small {
        font-size: 18px;
      }
    '';

  genIconUrl = i: "./assets/${toString i}.svg";

  concatSlideStrings = slides: (builtins.concatStringsSep "\n\n---\n\n" slides);

  genBasicSlide = {
    title,
    titleImage ? "",
    body,
    ...
  }: ''
    ${
      pkgs.lib.optionalString
      (builtins.stringLength titleImage > 0)
      "![image w:256 h:256](${titleImage})"
    }

    # ${title}

    ${body}
  '';

  genColumnsSlide = {
    title,
    bodies ? [],
    ...
  }: ''
    ### ${title}

    <div class="columns">
    ${
      lib.strings.concatLines (builtins.map (
          body: ''
            <div class="col">

            ${body}

            </div>
          ''
        )
        bodies)
    }
    </div>
  '';

  genNumberedTitleSlide = {
    title,
    slideGroups ? [],
    ...
  }:
    ''
      ### ${title}

    ''
    + builtins.concatStringsSep "\n" (
      lib.lists.imap1 (
        i: slide: "![${toString i}](${genIconUrl i}) ${slide.title}"
      )
      slideGroups
    );

  genNumberedSlideGroup = {
    title,
    index,
    slides ? [],
    ...
  }: let
    icon = genIconUrl index;
    titleSlide = ''
      <!-- _class: lead -->

      ![${toString index} w:256 h:256](${icon})

      # ${title}
    '';
    contentSlides = builtins.map (slide: ("![${toString index}](${icon})\n" + genSlide slide)) slides;
  in
    concatSlideStrings ([titleSlide] ++ contentSlides);

  genNumbered = {
    title,
    slideGroups ? [],
    ...
  } @ slide: let
    titleSlide = genNumberedTitleSlide slide;
    slideGroupsSlides =
      lib.lists.imap1 (
        index: slideGroup: (concatSlideStrings [
          titleSlide
          (genNumberedSlideGroup (slideGroup // {inherit index;}))
        ])
      )
      slideGroups;
  in
    concatSlideStrings slideGroupsSlides;

  genScopedDirectives = {center ? false, ...}:
    if center
    then "<!-- _class: lead -->\n"
    else "\n";

  genSlide = slide:
    genScopedDirectives slide
    + (
      if slide.type == "basic"
      then genBasicSlide slide
      else if slide.type == "numbered"
      then genNumbered slide
      else if slide.type == "columns"
      then genColumnsSlide slide
      else throw "Invalid slide type"
    );

  titleSlide = {
    type = "basic";
    title = title;
    titleImage = titleImage;
    center = true;
    body = ''
      ${description}

      **By ${builtins.concatStringsSep " and " authors}**
    '';
  };
in
  ''
    ---
    title: ${title}
    description: ${description}
    author: ${builtins.elemAt authors 0}
    theme: ${theme}
    transition: fade
    style: |
    ${builtins.concatStringsSep "\n" (builtins.map (x: "  ${x}") (lib.strings.splitString "\n" style))}
    ---
    <link rel="stylesheet" href="./code-theme.css">

  ''
  + concatSlideStrings (builtins.map genSlide ([titleSlide] ++ slides))
