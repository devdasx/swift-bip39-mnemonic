plugins {
    kotlin("jvm") version "2.0.21"
    `maven-publish`
}

group = "com.devdasx"
version = "1.1.3"

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
            groupId = "com.devdasx"
            artifactId = "swiftbip39"
            version = project.version.toString()
        }
    }
}
