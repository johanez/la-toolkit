import 'package:la_toolkit/models/laServiceDesc.dart';

final Map<String, LAServiceDesc> serviceDescList = {
  "collectory": LAServiceDesc(
      name: "collections",
      nameInt: "collectory",
      desc: "biodiversity collections",
      optional: false,
      sample: "https://collections.ala.org.au",
      path: ""),
  "ala_hub": LAServiceDesc(
      name: "records",
      nameInt: "ala_hub",
      desc: "occurrences search frontend",
      optional: false,
      hint: "Typically 'records' or similar",
      sample: "https://biocache.ala.org.au",
      path: ""),
  "biocache_service": LAServiceDesc(
      name: "records-ws",
      nameInt: "biocache_service",
      desc: "occurrences web service",
      optional: false,
      sample: "https://biocache.ala.org.au/ws",
      path: ""),
  "ala_bie": LAServiceDesc(
      name: "species",
      nameInt: "ala_bie",
      desc: "species search frontend",
      optional: true,
      initUse: true,
      sample: "https://bie.ala.org.au",
      path: ""),
  "bie_index": LAServiceDesc(
      name: "species-ws",
      nameInt: "bie_index",
      desc: "species web service",
      depends: "ala_bie",
      optional: false,
      sample: "https://bie.ala.org.au/ws",
      path: ""),
  "images": LAServiceDesc(
      name: "images",
      nameInt: "images",
      desc: "images service",
      optional: true,
      initUse: true,
      sample: "https://images.ala.org.au",
      path: ""),
  "species_lists": LAServiceDesc(
      name: "lists",
      nameInt: "species_lists",
      desc: "user provided species lists",
      depends: "ala_bie",
      optional: true,
      initUse: true,
      sample: "https://lists.ala.org.au",
      path: ""),
  "regions": LAServiceDesc(
      name: "regions",
      nameInt: "regions",
      desc: "regional data frontend",
      depends: "spatial",
      optional: true,
      initUse: true,
      sample: "https://regions.ala.org.au",
      path: ""),
  "logger": LAServiceDesc(
      name: "logger",
      nameInt: "logger",
      desc: "event logging (downloads stats, etc)",
      optional: false,
      sample: "https://logger.ala.org.au",
      path: ""),
  "solr": LAServiceDesc(
      name: "index",
      nameInt: "solr",
      desc: "indexing (Solr)",
      optional: false,
      path: ""),
  "cas": LAServiceDesc(
      name: "auth",
      nameInt: "cas",
      desc: "CAS authentication system",
      optional: true,
      initUse: true,
      forceSubdomain: true,
      sample: "https://auth.ala.org.au/cas/",
      recommended: true,
      path: ""),
  "biocache_backend": LAServiceDesc(
      name: "biocache-backend",
      nameInt: "biocache_backend",
      desc: "cassandra and biocache-store backend",
      withoutUrl: true,
      optional: false,
      path: ""),
  "branding": LAServiceDesc(
      name: "branding",
      nameInt: "branding",
      desc: "Web branding used by all services",
      withoutUrl: true,
      optional: false,
      path: ""),
  "biocache_cli": LAServiceDesc(
      name: "biocache-cli",
      nameInt: "biocache_cli",
      desc:
          "manages the loading, sampling, processing and indexing of occurrence records",
      optional: false,
      path: ""),
  "spatial": LAServiceDesc(
      name: "spatial",
      nameInt: "spatial",
      desc: "spatial front-end",
      optional: true,
      initUse: true,
      forceSubdomain: true,
      sample: "https://spatial.ala.org.au",
      path: ""),
  "webapi": LAServiceDesc(
      name: "webapi",
      nameInt: "webapi",
      desc: "API front-end",
      optional: true,
      initUse: false,
      sample: "https://api.ala.org.au",
      path: ""),
  "dashboard": LAServiceDesc(
      name: "dashboard",
      nameInt: "dashboard",
      desc: "work in progress",
      optional: true,
      initUse: false,
      sample: "https://dashboard.ala.org.au",
      path: ""),
  "alerts": LAServiceDesc(
      name: "alerts",
      nameInt: "alerts",
      desc:
          "users can subscribe to notifications about new species occurrences they are interested, regions, etc",
      optional: true,
      initUse: false,
      sample: "https://alerts.ala.org.au",
      path: ""),
  "doi": LAServiceDesc(
      name: "doi",
      nameInt: "doi",
      desc: "mainly used for generating DOIs of user downloads",
      optional: true,
      initUse: false,
      sample: "https://doi.ala.org.au",
      path: ""),
  "nameindexer": LAServiceDesc(
      name: "nameindexer",
      nameInt: "nameindexer",
      desc: "nameindexer",
      optional: false,
      path: "")
};

/*
Map<String, bool> getLAServicesDefUse() {
  final Map<String, bool> serviceDescUseList = {};
  serviceDescList.forEach((key, value) {
    serviceDescUseList[key] = !value.optional ? true : value.initUse;
  });
  return serviceDescUseList;
} */
