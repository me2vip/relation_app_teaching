import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ========================================================================
// 签名配置加载（优先级：CI 环境变量 > android/key.properties 文件）
// ========================================================================
// 本地开发：将 keystore 路径/密码写入 android/key.properties（已加入 .gitignore）
// CI / GitHub Actions：通过环境变量注入：
//   ANDROID_KEYSTORE_PATH     keystore 文件路径（CI 会解码 base64 后写入）
//   ANDROID_KEY_ALIAS        密钥别名
//   ANDROID_KEY_PASSWORD     密钥密码
//   ANDROID_STORE_PASSWORD   存储密码
// ========================================================================

data class SigningConfigData(
    val keyAlias: String,
    val keyPassword: String,
    val storeFile: java.io.File,
    val storePassword: String,
)

fun loadSigningConfig(): SigningConfigData? {
    // 1) 先看 CI 环境变量（在 GitHub Actions 中使用）
    val envStorePath = System.getenv("ANDROID_KEYSTORE_PATH")
    val envAlias = System.getenv("ANDROID_KEY_ALIAS")
    val envKeyPass = System.getenv("ANDROID_KEY_PASSWORD")
    val envStorePass = System.getenv("ANDROID_STORE_PASSWORD")
    if (!envStorePath.isNullOrBlank() && !envAlias.isNullOrBlank()
        && !envKeyPass.isNullOrBlank() && !envStorePass.isNullOrBlank()) {
        val f = rootProject.file(envStorePath)
        if (f.exists()) {
            println("✅ [签名] 使用 CI 环境变量加载签名 (store=${f.absolutePath})")
            return SigningConfigData(envAlias, envKeyPass, f, envStorePass)
        } else {
            println("⚠️  [签名] 环境变量中指明的 keystore 不存在：${f.absolutePath}")
        }
    }

    // 2) 再看 android/key.properties（本地开发）
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
        val storeFileProp = keystoreProperties["storeFile"] as? String
        if (!storeFileProp.isNullOrBlank()) {
            val f = rootProject.file(storeFileProp)
            val alias = keystoreProperties["keyAlias"] as? String
            val kp = keystoreProperties["keyPassword"] as? String
            val sp = keystoreProperties["storePassword"] as? String
            if (f.exists() && !alias.isNullOrBlank() && !kp.isNullOrBlank() && !sp.isNullOrBlank()) {
                println("✅ [签名] 使用 android/key.properties 加载签名 (store=${f.absolutePath})")
                return SigningConfigData(alias, kp, f, sp)
            }
        }
    }

    println("ℹ️  [签名] 未检测到 release 签名配置，将退化为 debug 签名")
    return null
}

val releaseSigning: SigningConfigData? = loadSigningConfig()

android {
    namespace = "com.teaching.relation_app_teaching"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.teaching.relation_app_teaching"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val cfg = releaseSigning
            if (cfg != null) {
                keyAlias = cfg.keyAlias
                keyPassword = cfg.keyPassword
                storeFile = cfg.storeFile
                storePassword = cfg.storePassword
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 如果有 release 签名就用，没有则退化（Flutter release build 会报错 → 使用 debug 签名兜底）
            signingConfig = signingConfigs.getByName("release").takeIf {
                releaseSigning != null
            } ?: signingConfigs.getByName("debug")
        }
        // 调试版本额外输出 debug symbols，方便 PR 构建测试
        debug {
            isMinifyEnabled = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
