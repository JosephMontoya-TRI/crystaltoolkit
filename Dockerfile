FROM python:3.7
LABEL maintainer="mkhorton@lbl.gov"

RUN mkdir -p /home/project/dash_app
WORKDIR /home/project/dash_app

RUN pip install --no-cache-dir numpy scipy

# Install special pymatgen
RUN pip install git+https://github.com/montoyjh/pymatgen.git@fast_pourbaix

ADD requirements.txt /home/project/dash_app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Dash callbacks are blocking, and also often network-limited
# rather than CPU-limited, so using NUM_WORKERS >> number of
# CPU cores is sensible
ENV CRYSTAL_TOOLKIT_NUM_WORKERS=4

# for Crossref API, used for DOI lookups
ENV CROSSREF_MAILTO=joseph.montoya@tri.global

# Run with setup in docker run
# this can be obtained from materialsproject.org
# ENV PMG_MAPI_KEY=None

# whether to run the server in debug mode or not
ENV CRYSTAL_TOOLKIT_DEBUG_MODE=False

ADD . /home/project/dash_app

EXPOSE 8000
CMD gunicorn --workers=$CRYSTAL_TOOLKIT_NUM_WORKERS --worker-class=gevent --worker-connections=1000 \
    --threads=2 --timeout=300 --bind=0.0.0.0 pbx_app:server
