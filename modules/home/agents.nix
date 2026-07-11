# AI coding-agent session wrappers: the declarative config for the
# `claude-session` and `codex-session` host wrappers. Only static, portable
# config lives here — never live/mutable state (credentials, auth caches,
# session directories, lock files), which the wrappers manage under HOME on
# their own. Work-specific and personal layers (the `suse` claude profile, the
# codex trusted-projects list) are overlaid by the private consumer.
{ publicAssetsDir, ... }:

{
  xdg.configFile = {
    # claude-session — portable base layer.
    "claude-session/config.env".source = publicAssetsDir + "/claude-session/config.env";
    "claude-session/profiles/default.yaml".source =
      publicAssetsDir + "/claude-session/profiles/default.yaml";
    "claude-session/settings/base.json".source = publicAssetsDir + "/claude-session/settings/base.json";

    # codex-session — portable config recipe, layers, and profile tiers.
    "codex-session/config.toml".source = publicAssetsDir + "/codex-session/config.toml";
    "codex-session/config-recipes/default.yaml".source =
      publicAssetsDir + "/codex-session/config-recipes/default.yaml";
    "codex-session/configs/base.toml".source = publicAssetsDir + "/codex-session/configs/base.toml";
    # Portable empty `projects` layer. The `default` recipe names it, so it must
    # exist or config-recipe composition fails; the private consumer overrides it
    # with the personal trusted-projects list via lib.mkForce.
    "codex-session/configs/projects.toml".source =
      publicAssetsDir + "/codex-session/configs/projects.toml";
    "codex-session/configs/plugins.toml".source =
      publicAssetsDir + "/codex-session/configs/plugins.toml";
    "codex-session/profiles/deep.config.toml".source =
      publicAssetsDir + "/codex-session/profiles/deep.config.toml";
    "codex-session/profiles/low.config.toml".source =
      publicAssetsDir + "/codex-session/profiles/low.config.toml";
    "codex-session/profiles/medium.config.toml".source =
      publicAssetsDir + "/codex-session/profiles/medium.config.toml";
    "codex-session/profiles/ping.config.toml".source =
      publicAssetsDir + "/codex-session/profiles/ping.config.toml";
    "codex-session/profiles/quick.config.toml".source =
      publicAssetsDir + "/codex-session/profiles/quick.config.toml";
  };
}
