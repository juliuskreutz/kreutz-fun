{
  config,
  ...
}:
{
  services.prometheus = {
    enable = true;
    extraFlags = [ "--web.enable-remote-write-receiver" ];
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9096;
        log_level = "debug";
        grpc_server_max_concurrent_streams = 1000;
      };

      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/tmp/loki";
        storage = {
          filesystem = {
            chunks_directory = "/tmp/loki/chunks";
            rules_directory = "/tmp/loki/rules";
          };
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };

      query_range.results_cache.cache.embedded_cache = {
        enabled = true;
        max_size_mb = 100;
      };

      limits_config.metric_aggregation_enabled = true;

      schema_config.configs = [
        {
          from = "2020-10-24";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      pattern_ingester = {
        enabled = true;
        metric_aggregation.loki_address = "localhost:3100";
      };

      ruler.alertmanager_url = "http://localhost:9093";
      frontend.encoding = "protobuf";
    };
  };

  services.alloy.enable = true;
  environment.etc."alloy/config.alloy".text = ''
    prometheus.exporter.unix "default" {
    }

    prometheus.scrape "unix" {
      targets = prometheus.exporter.unix.default.targets
      forward_to = [prometheus.remote_write.default.receiver]
    }

    prometheus.scrape "caddy" {
      targets = [{__address__ = "localhost:2019"}]
      scrape_interval = "15s"
      forward_to = [prometheus.remote_write.default.receiver]
    }

    prometheus.remote_write "default" {
      endpoint {
        url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}/api/v1/write"
      }
    }

    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.source.journal "journal" {
      forward_to = [loki.write.default.receiver]
      relabel_rules = loki.relabel.journal.rules
    }

    loki.write "default" {
      endpoint {
        url = "http://localhost:3100/loki/api/v1/push"
      }
    }
  '';

  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "grafana.kreutz.fun";
      };
    };
    provision.datasources.settings = {
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://${config.services.loki.configuration.common.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}";
        }
        {
          name = "PostgreSQL";
          type = "postgres";
          url = "${config.services.postgresql.settings.listen_addresses}:${toString config.services.postgresql.settings.port}";
          user = "postgres";
          jsonData = {
            database = "mirrorfour";
            postgresVersion = 1500;
            sslmode = "disable";
          };
          secureJsonData.password = "postgres";
        }
      ];
    };
  };

  services.caddy = {
    virtualHosts.${config.services.grafana.settings.server.domain}.extraConfig = ''
      reverse_proxy http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}
    '';
    virtualHosts."alloy.kreutz.fun".extraConfig = ''
      reverse_proxy http://localhost:12345
    '';
  };
}
