# My Nix/NixOS Presentation

This is cool proof-of-concept I made for my Nix/NixOS technical seminar for the Computer Science House.

I thought it'd be kind of funny to make a presentation with the cool tool I'm describing.

## Building

```
nix build --file ./default.nix
```

A `result/` directory should appear with the required files inside.

## Developing

I added a small `shell.nix` to quickly test my code which can be entered with the following command.

```
nix-shell
```
