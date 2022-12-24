{ pkgs }: {
    deps = [
        pkgs.bashInteractive
        pkgs.man
        pkgs.wget
        pkgs.caddy
        pkgs.busybox
    ];
}