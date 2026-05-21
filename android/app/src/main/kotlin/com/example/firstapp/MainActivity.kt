package com.example.firstapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import javax.net.ssl.*
import java.security.cert.X509Certificate
import java.security.SecureRandom

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupDownloadChannel(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "native/http")
            .setMethodCallHandler { call, result ->
                if (call.method == "post") {
                    val url = call.argument<String>("url") ?: run {
                        result.error("INVALID_ARG", "url is required", null)
                        return@setMethodCallHandler
                    }
                    val body = call.argument<String>("body") ?: ""
                    Thread {
                        try {
                            val responseBody = postFollowingRedirects(url, body)
                            runOnUiThread { result.success(responseBody) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("HTTP_ERROR", e.message, null) }
                        }
                    }.start()
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun postFollowingRedirects(startUrl: String, body: String): String {
        var currentUrl = startUrl
        repeat(5) {
            val conn = URL(currentUrl).openConnection() as HttpURLConnection
            if (conn is HttpsURLConnection) {
                conn.sslSocketFactory = trustAllSocketFactory()
                conn.hostnameVerifier = HostnameVerifier { _, _ -> true }
            }
            conn.instanceFollowRedirects = false
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json")
            conn.setRequestProperty("Accept", "application/json")
            conn.setRequestProperty("User-Agent", "SugarProductionApp/1.0 (Android)")
            conn.connectTimeout = 15_000
            conn.readTimeout = 15_000
            conn.doOutput = true
            conn.outputStream.use { it.write(body.toByteArray(Charsets.UTF_8)) }

            val code = conn.responseCode
            android.util.Log.d("NativeHTTP", "POST $currentUrl → $code")

            if (code in 301..308) {
                val location = conn.getHeaderField("Location") ?: throw Exception("Redirect with no Location header")
                currentUrl = if (location.startsWith("http")) location
                             else "https://cattarlac.com$location"
                conn.disconnect()
                return@repeat
            }

            val respBody = if (code < 400) {
                conn.inputStream.bufferedReader(Charsets.UTF_8).readText()
            } else {
                conn.errorStream?.bufferedReader(Charsets.UTF_8)?.readText() ?: ""
            }
            return "[$code] $respBody"
        }
        throw Exception("Too many redirects")
    }

    private fun setupDownloadChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "native/download")
            .setStreamHandler(object : EventChannel.StreamHandler {
                @Volatile private var cancelled = false
                private var thread: Thread? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    cancelled = false
                    val args = arguments as? Map<*, *> ?: run {
                        events.error("INVALID_ARG", "arguments must be a map", null); return
                    }
                    val url = args["url"] as? String ?: run {
                        events.error("INVALID_ARG", "url required", null); return
                    }
                    val filePath = args["filePath"] as? String ?: run {
                        events.error("INVALID_ARG", "filePath required", null); return
                    }

                    thread = Thread {
                        try {
                            val conn = openPostFollowingRedirects(url)
                            val total = conn.contentLengthLong
                            var received = 0L
                            var lastPercent = -1
                            val file = File(filePath)
                            file.parentFile?.mkdirs()

                            conn.inputStream.use { input ->
                                file.outputStream().use { output ->
                                    val buf = ByteArray(8192)
                                    var n = 0
                                    while (!cancelled && input.read(buf).also { n = it } != -1) {
                                        output.write(buf, 0, n)
                                        received += n
                                        val pct = if (total > 0) (received * 100 / total).toInt() else 0
                                        if (pct > lastPercent) {
                                            lastPercent = pct
                                            val snap = received
                                            runOnUiThread {
                                                events.success(mapOf(
                                                    "progress" to if (total > 0) snap.toDouble() / total else 0.0,
                                                    "received" to snap,
                                                    "total"    to total,
                                                    "done"     to false,
                                                ))
                                            }
                                        }
                                    }
                                }
                            }

                            if (!cancelled) {
                                runOnUiThread {
                                    events.success(mapOf(
                                        "progress" to 1.0,
                                        "received" to received,
                                        "total"    to received,
                                        "done"     to true,
                                        "filePath" to filePath,
                                    ))
                                    events.endOfStream()
                                }
                            }
                        } catch (e: Exception) {
                            if (!cancelled) runOnUiThread { events.error("DOWNLOAD_ERROR", e.message, null) }
                        }
                    }
                    thread!!.start()
                }

                override fun onCancel(arguments: Any?) {
                    cancelled = true
                    thread?.interrupt()
                    thread = null
                }

                private fun openPostFollowingRedirects(startUrl: String): HttpURLConnection {
                    var currentUrl = startUrl
                    repeat(5) {
                        val conn = URL(currentUrl).openConnection() as HttpURLConnection
                        if (conn is HttpsURLConnection) {
                            conn.sslSocketFactory = trustAllSocketFactory()
                            conn.hostnameVerifier = HostnameVerifier { _, _ -> true }
                        }
                        conn.instanceFollowRedirects = false
                        conn.connectTimeout = 15_000
                        conn.readTimeout = 120_000
                        conn.connect()
                        val code = conn.responseCode
                        android.util.Log.d("NativeHTTP", "GET $currentUrl → $code")
                        if (code in 301..308) {
                            val loc = conn.getHeaderField("Location")
                                ?: throw Exception("Redirect missing Location")
                            currentUrl = if (loc.startsWith("http")) loc
                                         else "https://cattarlac.com$loc"
                            conn.disconnect()
                            return@repeat
                        }
                        return conn
                    }
                    throw Exception("Too many redirects")
                }
            })
    }

    private fun trustAllSocketFactory(): SSLSocketFactory {
        val trustAll = arrayOf<TrustManager>(object : X509TrustManager {
            override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
            override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
            override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
        })
        val sc = SSLContext.getInstance("TLS")
        sc.init(null, trustAll, SecureRandom())
        return sc.socketFactory
    }
}
