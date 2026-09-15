FROM debian:oldstable-slim

RUN sudo apt install cmatrix
ENTRYPOINT ["something.sh"]
