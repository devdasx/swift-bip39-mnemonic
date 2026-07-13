plugins {
    kotlin("jvm") version "2.0.21"
    `maven-publish`
}

group = findProperty("group")?.toString() ?: "com.devdasx.bip39"
version = findProperty("version")?.toString() ?: "2.0.1"

kotlin {
    jvmToolchain(17)

    sourceSets {
        main {
            kotlin.srcDir("kotlin/src/main/kotlin")
            resources.srcDir("kotlin/src/main/resources")
        }
        test {
            kotlin.srcDir("kotlin/src/test/kotlin")
            resources.srcDir("kotlin/src/test/resources")
        }
    }
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
