FROM nvcr.io/nvidia/cuda:11.2.0-runtime-ubuntu20.04
LABEL maintainer="Learning@home"
LABEL repository="hivemind"

WORKDIR /home
# Set en_US.UTF-8 locale by default
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment

# Install packages
RUN apt-get update && apt-get install -y --no-install-recommends --force-yes \
  build-essential \
  wget \
  git \
  vim \
  && apt-get clean autoclean && rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O install_miniconda.sh && \
  bash install_miniconda.sh -b -p /opt/conda && rm install_miniconda.sh
ENV PATH="/opt/conda/bin:${PATH}"

RUN conda install python~=3.8 pip && \
    pip install --no-cache-dir torch torchvision torchaudio && \
    conda clean --all

COPY requirements.txt hivemind/requirements.txt
COPY requirements-dev.txt hivemind/requirements-dev.txt
COPY examples/albert/requirements.txt hivemind/examples/albert/requirements.txt
RUN pip install --no-cache-dir -r hivemind/requirements.txt && \
    pip install --no-cache-dir -r hivemind/requirements-dev.txt && \
    pip install --no-cache-dir -r hivemind/examples/albert/requirements.txt && \
    rm -rf ~/.cache/pip

RUN conda install pytorch torchvision cudatoolkit=11 -c pytorch-nightly && \
    conda clean --all && rm -rf ~/.cache/pip && \
    pip uninstall --yes torchvision && \
    pip uninstall --yes torch && \
    pip install torch==1.8.1+cu111 -f https://download.pytorch.org/whl/torch_stable.html && \
    pip install torchvision

COPY . hivemind/
RUN cd hivemind && \
    pip install --no-cache-dir .[dev] && \
    conda clean --all && rm -rf ~/.cache/pip

ENV WANDB_ENTITY=hhz1992
ENV WANDB_PROJECT=albert
ENV WANDB_API_KEY=aa85d79cd9098c27f7d35ff8bf779b93c8265619

WORKDIR /home/hivemind/examples/albert