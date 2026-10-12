# Which app opens a file when you click it (Nautilus, Zen downloads, xdg-open).
# Written to ~/.config/mimeapps.list. Zen is the browser and opens web
# links, HTML and plain text (set by its module, see home/zen).
{ lib, pkgs, ... }:
let
  # everything Loupe can show (from its source, version in nixpkgs)
  images = [
    "image/apng"
    "image/bmp"
    "image/gif"
    "image/jp2"
    "image/jpeg"
    "image/png"
    "image/qoi"
    "image/tiff"
    "image/vnd.microsoft.icon"
    "image/webp"
    "image/x-dds"
    "image/x-exr"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-qoi"
    "image/x-tga"
    "image/x-win-bitmap"
    "image/x-xbitmap"
    "image/x-xpixmap"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/avif"
    "image/heic"
    "image/jxl"
  ];
  # every video type mpv registers itself for
  videos = [
    "video/mpeg"
    "video/x-mpeg2"
    "video/x-mpeg3"
    "video/mp4v-es"
    "video/x-m4v"
    "video/mp4"
    "video/divx"
    "video/vnd.divx"
    "video/msvideo"
    "video/x-msvideo"
    "video/ogg"
    "video/quicktime"
    "video/vnd.rn-realvideo"
    "video/x-ms-afs"
    "video/x-ms-asf"
    "video/x-ms-wmv"
    "video/x-ms-wmx"
    "video/x-ms-wvxvideo"
    "video/x-avi"
    "video/avi"
    "video/x-flic"
    "video/fli"
    "video/x-flc"
    "video/flv"
    "video/x-flv"
    "video/x-theora"
    "video/x-theora+ogg"
    "video/x-matroska"
    "video/mkv"
    "video/webm"
    "video/x-ogm"
    "video/x-ogm+ogg"
    "video/mp2t"
    "video/vnd.mpegurl"
    "video/3gp"
    "video/3gpp"
    "video/3gpp2"
    "video/dv"
    "video/vnd.avi"
  ];
  openWith = app: types: lib.genAttrs types (_: app);
in
{
  home.packages = with pkgs; [
    loupe # images
    mpv # videos
    # zathura (PDF) is in progressio.nix with the research tools
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      openWith "org.pwmt.zathura-pdf-mupdf.desktop" [ "application/pdf" ]
      // openWith "org.gnome.Loupe.desktop" images
      // openWith "mpv.desktop" videos
      # folders in the file manager (VS Code also claims folders)
      // openWith "org.gnome.Nautilus.desktop" [ "inode/directory" ];
  };
}
