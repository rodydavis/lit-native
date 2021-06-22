package com.example.webapp

import android.os.Bundle
import android.view.ViewGroup
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.setContent
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.viewinterop.AndroidView
import com.example.webapp.ui.theme.AppTheme
import java.net.URLEncoder
import java.util.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AppTheme {
                Screen("Android")
            }
        }
    }
}

@Composable
fun Screen(title: String) {
    AndroidView(
        modifier = Modifier.fillMaxSize(),
        viewBlock = {
            WebView(it).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
                webViewClient = WebViewClient()
                settings.javaScriptEnabled = true
                settings.javaScriptCanOpenWindowsAutomatically = true
                settings.allowContentAccess = true
                settings.allowFileAccess = true
                val tag = "my-element"
                val slot = ""
                val bundle = "build/bundle.es.js"
                var script = ""
                try {
                    script = context.assets.open(bundle).bufferedReader().use { it ->
                        it.readText()
                    }
//                    loadUrl(script)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                val htmlString = """
            <!DOCTYPE html>
            <html lang="en">
              <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no" />
                <title>${title}</title>
                <style>
                    body {
                        width: 100%;
                        height: 100vh;
                        padding: 0;
                        margin: 0;
                    }
                </style>
              </head>
              <body>
                <${tag}>
                    $slot
                </${tag}>
                <script>
                    $script
                </script>
              </body>
            </html>
                """
                loadData(htmlString, "text/html", "UTF-8")
            }
        },
        update = {

        }
    )
}

@Preview(showBackground = true)
@Composable
fun DefaultPreview() {
    AppTheme {
        Screen("Android")
    }
}