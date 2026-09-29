FROM openjdk:17-jdk-slim

LABEL maintainer="Jules Reynaud <jules.reynaud@epitech.eu>"
LABEL description="Docker image with Flutter and Android SDK for building Flutter apps"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        unzip \
        xz-utils \
        libglu1-mesa \
        git && \
    rm -rf /var/lib/apt/lists/*

ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH="$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$FLUTTER_HOME/bin"

RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    wget -qO sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
    unzip -q sdk-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm sdk-tools.zip


RUN yes | sdkmanager --licenses && \
    sdkmanager \
        "platform-tools" \
        "platforms;android-33" \
        "build-tools;34.0.0" \
        "emulator" \
        "tools"

RUN wget -qO flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz && \
    tar xf flutter.tar.xz -C /usr/local && \
    rm flutter.tar.xz

RUN useradd -ms /bin/bash builder && \
    mkdir -p /home/builder/app && \
    chown -R builder:builder /home/builder/app $FLUTTER_HOME $ANDROID_SDK_ROOT

USER builder

WORKDIR /home/builder/app

RUN flutter config --no-analytics && \
    flutter doctor --android-licenses && \
    flutter doctor -v && \
    flutter config --no-enable-web

RUN rm -rf $FLUTTER_HOME/.pub-cache/_temp && \
    rm -rf $FLUTTER_HOME/bin/cache/artifacts/engine/android-arm && \
    rm -rf $FLUTTER_HOME/bin/cache/artifacts/engine/android-arm64 && \
    rm -rf $FLUTTER_HOME/bin/cache/artifacts/engine/android-x64 && \
    rm -rf $FLUTTER_HOME/bin/cache/artifacts/engine/darwin-x64 && \
    rm -rf $FLUTTER_HOME/bin/cache/artifacts/engine/linux-x64/*clang* && \
    rm -rf $FLUTTER_HOME/bin/cache/artifacts/engine/windows-x64

CMD ["/bin/bash"]
