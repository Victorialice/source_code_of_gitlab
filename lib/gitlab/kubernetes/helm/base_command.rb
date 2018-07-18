module Gitlab
  module Kubernetes
    module Helm
      class BaseCommand
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def pod_resource
          Gitlab::Kubernetes::Helm::Pod.new(self, namespace).generate
        end

        def generate_script
          <<~HEREDOC
            set -eo pipefail
            ALPINE_VERSION=$(cat /etc/alpine-release | cut -d '.' -f 1,2)
            echo http://mirror.clarkson.edu/alpine/v$ALPINE_VERSION/main >> /etc/apk/repositories
            echo http://mirror1.hs-esslingen.de/pub/Mirrors/alpine/v$ALPINE_VERSION/main >> /etc/apk/repositories
            apk add -U wget ca-certificates openssl >/dev/null
            wget -q -O - https://kubernetes-helm.storage.googleapis.com/helm-v#{Gitlab::Kubernetes::Helm::HELM_VERSION}-linux-amd64.tar.gz | tar zxC /tmp >/dev/null
            mv /tmp/linux-amd64/helm /usr/bin/
          HEREDOC
        end

        def config_map?
          false
        end

        def pod_name
          "install-#{name}"
        end

        private

        def namespace
          Gitlab::Kubernetes::Helm::NAMESPACE
        end
      end
    end
  end
end
