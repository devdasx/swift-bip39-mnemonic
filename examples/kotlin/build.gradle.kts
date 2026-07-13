plugins {
    kotlin("jvm") version "2.0.21"
    application
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    implementation("com.github.devdasx:bip39-mnemonic-kit:2.0.1")
}

application {
    mainClass.set("ExampleKt")
}
