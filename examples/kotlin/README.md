# Kotlin / JVM example

This example installs the Kotlin/JVM package through JitPack from the GitHub tag.

## Install

Add JitPack and the dependency:

```kotlin
repositories {
    mavenCentral()
    maven("https://jitpack.io")
}

dependencies {
    implementation("com.github.devdasx:bip39-mnemonic-kit:2.0.1")
}
```

## Run

```bash
gradle run
```

This example requires Java 17.
