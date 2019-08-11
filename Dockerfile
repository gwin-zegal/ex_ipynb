
FROM jupyter/all-spark-notebook:latest

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    libgraphviz-dev &&\
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

# Conda package install 
RUN conda update -n base conda && \
    conda install --quiet --yes psycopg2 \
        plotly altair redis-py pymongo && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Pip package install
RUN pip install motor \
        ibis-framework pygraphviz eralchemy \
        ipython-sql ipython-cypher intake \
        postgres_kernel \
        networkx neo4j koalas pgspecial \
        umap-learn memory_profiler \
        watermark && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# sparkmagic
# RUN  jupyter-kernelspec install \
#         /opt/conda/lib/python3.7/site-packages/sparkmagic/kernels/pysparkkernel && \
#      jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
#      jupyter serverextension enable --py sparkmagic && \
#      fix-permissions /home/$NB_USER

# RUN python -m postgres_kernel install
# mkdir /opt/conda/share/jupyter/kernels/postgres &&\
#     ln -s /opt/conda/lib/python3.7/site-packages/postgres_kernel/kernel.py \
#     /opt/conda/share/jupyter/kernels/postgres

RUN mkdir /opt/conda/share/jupyter/kernels/PostgreSQL
COPY kernels/PostgreSQL /opt/conda/share/jupyter/kernels/PostgreSQL

RUN fix-permissions /opt/conda/share/jupyter/kernels

RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN fix-permissions /etc/jupyter/

COPY lib/jars/* /usr/local/spark/jars/
RUN chmod 644 /usr/local/spark/jars/*

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID