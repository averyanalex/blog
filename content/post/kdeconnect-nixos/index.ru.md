---
title: "Установка KDE Connect (GSConnect) на NixOS"
date: 2024-09-13T01:20:52+03:00
tags: [NixOS]
---

## KDE

### Без использования home manager

```nix
programs.kdeconnect.enable = true;
# нужные порты будут открыты автоматически
```

### С home manager

```nix
home-manager.users.username.services.kdeconnect.enable = true;

# home-manager не может менять системные настройки, поэтому откроем порты вручную
# скопировано из https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/kdeconnect.nix
networking.firewall = rec {
  allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  allowedUDPPortRanges = allowedTCPPortRanges;
};
```

## GNOME

### Без использования home manager

```nix
programs.kdeconnect = {
  enable = true;
  package = pkgs.gnomeExtensions.gsconnect;
};
```

После этого необходимо включить расширение GSConnect в приложении "Расширения"
(Extensions).

### С home manager

```nix
home-manager.users.username.programs.gnome-shell = {
  enable = true;
  extensions = [{ package = pkgs.gnomeExtensions.gsconnect; }];
};

# home-manager не может менять системные настройки, поэтому откроем порты вручную
# скопировано из https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/kdeconnect.nix
networking.firewall = rec {
  allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  allowedUDPPortRanges = allowedTCPPortRanges;
};
```

Home Manager автоматически добавит расширение в список включенных в dconf,
поэтому включать его через "Расширения" не потребуется.
