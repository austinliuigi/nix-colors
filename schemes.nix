{ lib, schemes-source, ... }:
let
  inherit (builtins)
    readFile readDir attrNames listToAttrs stringLength substring baseNameOf filter;

  # Borrowed from nixpkgs
  removeSuffix = suffix: str:
    let
      sufLen = stringLength suffix;
      sLen = stringLength str;
    in
    if sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str then
      substring 0 (sLen - sufLen) str
    else
      str;

  hasSuffix = suffix: content:
    let
      lenContent = stringLength content;
      lenSuffix = stringLength suffix;
    in
    lenContent >= lenSuffix
    && substring (lenContent - lenSuffix) lenContent content == suffix;

  stripYamlExtension = filename:
    removeSuffix ".yml" (removeSuffix ".yaml" filename);

  isYamlFile = filename:
    (hasSuffix ".yml" filename) || (hasSuffix ".yaml" filename);

  base16ColorSchemeFiles = filter isYamlFile (attrNames (readDir "${schemes-source}/base16"));
  base24ColorSchemeFiles = filter isYamlFile (attrNames (readDir "${schemes-source}/base24"));

  base16ColorSchemes = listToAttrs (map
    (filename: rec {
      name = stripYamlExtension (baseNameOf filename); # scheme slug
      value = lib.base16SchemeFromYAML name (readFile "${schemes-source}/base16/${filename}"); # scheme contents
    })
    base16ColorSchemeFiles);

  base24ColorSchemes = listToAttrs (map
    (filename: rec {
      name = stripYamlExtension (baseNameOf filename); # scheme slug
      value = lib.base24SchemeFromYAML name (readFile "${schemes-source}/base24/${filename}"); # scheme contents
    })
    base24ColorSchemeFiles);
in
  {
    base16 = base16ColorSchemes;
    base24 = base24ColorSchemes;
  }
