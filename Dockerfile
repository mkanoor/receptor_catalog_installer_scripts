# Dockerfile using RHEL8
# You should login using 
# docker login https://registry.redhat.io
FROM registry.redhat.io/rhel8/python-36
ARG USERNAME
ARG PASSWORD
ARG RHSM_POOL_ID
ARG RHSM_URL=https://subscription.rhsm.redhat.com/subscription
RUN test -n "$RHSM_POOL_ID" || (echo "Please set RHSM_POOL_ID" && false)
USER root

RUN subscription-manager register --serverurl $RHSM_URL --username $USERNAME --password $PASSWORD --auto-attach
RUN subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
RUN subscription-manager attach --pool $RHSM_POOL_ID
RUN subscription-manager repos --enable automation-services-catalog-1-beta-for-rhel-8-x86_64-rpms
RUN dnf -y install ansible
RUN ansible-galaxy install mkanoor.catalog_receptor_installer

COPY entrypoint.sh /bin/entrypoint.sh
CMD /bin/entrypoint.sh install_receptor.yml
