FROM node:6-stretch

RUN mkdir /usr/src/goof
RUN mkdir /tmp/extracted_files
COPY . /usr/src/goof
WORKDIR /usr/src/goof

RUN npm update
RUN npm install

COPY . .

EXPOSE 3001
EXPOSE 9229
ENTRYPOINT ["npm", "start"]
