FROM julesreyn/flutter-android-sdk:latest

USER root

WORKDIR /home/builder/app

COPY . .

RUN chown -R builder:builder /home/builder/app

USER builder

RUN flutter pub get
RUN flutter build apk --release

CMD ["tail", "-f", "/dev/null"]
