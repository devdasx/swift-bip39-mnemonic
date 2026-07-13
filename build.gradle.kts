plugins {
    kotlin("jvm") version "2.0.21"
    `maven-publish`
}

group = findProperty("group")?.toString() ?: "com.devdasx.bip39"
version = findProperty("version")?.toString() ?: "2.0.0"

kotlin {
    jvmToolchain(17)
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.17.2")
}

tasks.test {
    useJUnitPlatform()
}

publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])
            groupId = project.group.toString()
            artifactId = "bip39-mnemonic-kit"
            version = project.version.toString()
        }
    }
}
