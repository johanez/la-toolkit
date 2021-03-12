class TagsConstants {
  static final List<String> v2_0_5 = [
    "alerts",
    "always",
    "apikey",
    "apikeys_add",
    "apt_update",
    "augeas",
    "backup",
    "bie",
    "bie-index",
    "bie_index",
    "biocache-cli",
    "biocache-cli-symlink",
    "biocache-cli-update",
    "biocache_db",
    "biocache_hub",
    "biocache-layers",
    "biocache-properties",
    "biocache-service",
    "cas",
    "cas-management",
    "cassandra",
    "cassandra_yaml",
    "collectory",
    "common",
    "config",
    "createdb",
    "dashboard",
    "data_archives",
    "data_import",
    "db",
    "dbfix",
    "dbtest",
    "demo",
    "demo-etc-hosts",
    "deploy",
    "doi-service",
    "download-zip",
    "ecodata",
    "ecodata-geoserver",
    "elasticsearch",
    "extension",
    "facets_config",
    "geoip",
    "geolite_db",
    "geonetwork",
    "geoserver",
    "geoserver_run_script",
    "hub_config",
    "i18n",
    "image-service",
    "info",
    "install",
    "java",
    "layers-db",
    "logger-service",
    "mongodb-org",
    "mysql-5.7",
    "mysql-server",
    "namedata",
    "nameindex",
    "nameindexer",
    "nameindex-stage",
    "nameindex-swap",
    "nginx_vhost",
    "packages",
    "password",
    "pg_instance",
    "plugins",
    "postfix",
    "postgis",
    "postgresql",
    "properties",
    "regions",
    "service",
    "setfacts",
    "solr7",
    "solr7_check_running",
    "solr7_create_cores",
    "solr_restart",
    "spatial-hub",
    "spatial-hub-config",
    "spatial-hub-deploy",
    "spatial-service",
    "spatial-service-config",
    "spatial-service-deploy",
    "specieslist",
    "symlinks",
    "templates",
    "tomcat",
    "tomcat_vhost",
    "user",
    "userdetails",
    "version_check",
    "vocabs",
    "webapi",
    "webapps",
    "webserver",
    "xpack"
  ];

  static final Map<String, List<String>> _map = {
    "v2.0.5": v2_0_5,
    "v2.0.4": v2_0_5,
    "upstream": v2_0_5,
    "custom": v2_0_5,
  };

  static List<String> getTagsFor(String alaInstallVersion) {
    if (_map.containsKey(alaInstallVersion))
      return v2_0_5;
    else
      return _map[alaInstallVersion];
  }
}
