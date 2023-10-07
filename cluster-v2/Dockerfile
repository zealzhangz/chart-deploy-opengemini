FROM openeuler/openeuler

RUN mkdir -p /opt/openGemini/bin
RUN mkdir -p /opt/openGemini/scripts

COPY v1.1.0/ts-* /opt/openGemini/bin/
COPY cluster-v2/scripts/start.sh /opt/openGemini/scripts/start.sh

RUN chmod +x /opt/openGemini/bin/*
RUN chmod +x /opt/openGemini/scripts/*

ENTRYPOINT ["/opt/openGemini/scripts/start.sh"]